import Combine
import Foundation
#if os(watchOS)
import WatchKit
#endif

@MainActor
final class SnorkelingWatchRuntimeStore: ObservableObject {
    static private(set) weak var shared: SnorkelingWatchRuntimeStore?

    @Published private(set) var presentationInput: SnorkelingWatchPresentationInput = .idle
    @Published private(set) var lifecyclePhase: SnorkelingLifecyclePhase = .idle
    @Published var showSessionSummary = false
    @Published var showSaveMarker = false
    @Published var selectedMarkerCategory: SnorkelingMarkerCategory = .reef
    @Published private(set) var sessionSaveState: SnorkelingWatchSessionSaveState = .notSaved
    private var lastBatteryFraction: Double?
    @Published private(set) var lastMarkerSavedConfirmation: String?
    @Published private(set) var isRecoveredSession = false
    @Published private(set) var checkpointRestoreWarning: String?

    private var engine = SnorkelingSessionEngine()
    private var depthProvider: DepthSensorProvider?
    private var activeDepthSensorMetadata = DepthSensorSessionMetadata()
    private var tickTask: Task<Void, Never>?
    private var checkpointTask: Task<Void, Never>?
    private var gpsCancellable: AnyCancellable?
    private var compassCancellable: AnyCancellable?
    private var sessionArmed = false
    private var sessionStarted = false
    private var missionModeEnabled = false
    private var hapticsEnabled = true
    private var buddyReminderEnabled = false
    private var dismissedOverlayEventIDs: Set<UUID> = []
    private var firedHapticKeys: Set<UUID> = []
    private var lastHeadingSample: (degrees: Double, date: Date)?
    private weak var gpsManager: GPSManager?
    private weak var compassManager: CompassManager?

    #if DEBUG
    static var testHook_checkpointURL: URL?
    static var testHook_checkpointWriteCount = 0
    #endif

    private var lastCheckpointFingerprint: String?

    init() {
        Self.shared = self
        if !restoreCheckpointIfPresent() {
            configureDefaultSession()
        }
        refreshPresentation()
    }

    var isSessionActive: Bool {
        sessionStarted && lifecyclePhase != .ended && lifecyclePhase != .idle
    }

    func attachSensorManagers(gps: GPSManager, compass: CompassManager) {
        gpsManager = gps
        compassManager = compass
    }

    func configureRuntimePreferences(hapticsEnabled: Bool, missionModeEnabled: Bool, buddyReminderEnabled: Bool) {
        self.hapticsEnabled = hapticsEnabled
        self.missionModeEnabled = missionModeEnabled
        self.buddyReminderEnabled = buddyReminderEnabled
        engine.setMissionModeEnabled(missionModeEnabled)
        engine.setHapticsEnabled(hapticsEnabled)
        refreshPresentation()
    }

    func armSession(at wallClock: Date = Date()) {
        configureDefaultSession()
        engine.resetRouteRuntimeTracking()
        engine.armSession(at: wallClock)
        sessionArmed = true
        sessionStarted = false
        showSessionSummary = false
        showSaveMarker = false
        sessionSaveState = .notSaved
        dismissedOverlayEventIDs.removeAll()
        firedHapticKeys.removeAll()
        isRecoveredSession = false
        checkpointRestoreWarning = nil
        startSensors()
        startBackgroundLoops()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func startSession(at wallClock: Date = Date()) {
        if !sessionArmed {
            armSession(at: wallClock)
        }
        captureEntrySurfaceFix(at: wallClock)
        engine.startSession(at: wallClock)
        sessionStarted = true
        persistCheckpointSoon()
        refreshPresentation()
    }

    func endSession(at wallClock: Date = Date()) {
        captureExitSurfaceFix(at: wallClock)
        engine.endSession(at: wallClock)
        showSessionSummary = true
        stopSensors()
        stopBackgroundLoops()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func requestSessionSummary() {
        showSessionSummary = true
        refreshPresentation()
    }

    func presentSaveMarker() {
        guard isSessionActive else { return }
        showSaveMarker = true
        refreshPresentation()
    }

    func dismissSaveMarker() {
        showSaveMarker = false
        refreshPresentation()
    }

    func enterNavigation() {
        engine.enterNavigation()
        showSaveMarker = false
        persistCheckpointSoon()
        refreshPresentation()
    }

    func enterReturnMode() {
        engine.enterReturnMode()
        showSaveMarker = false
        persistCheckpointSoon()
        refreshPresentation()
    }

    func exitNavigationOrReturn() {
        engine.exitNavigationOrReturn()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func pauseSession() {
        engine.pauseSession()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func resumeSession() {
        engine.resumeSession()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func enableManualFallback() {
        engine.enableManualFallback()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func triggerManualDipStart() {
        engine.triggerManualDipStart()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func triggerManualDipEnd() {
        engine.triggerManualDipEnd()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func saveMarker(allowWithoutCoordinates: Bool = true) {
        let result = engine.saveMarker(
            request: SnorkelingMarkerCaptureRequest(
                category: selectedMarkerCategory,
                allowSaveWithoutCoordinates: allowWithoutCoordinates
            )
        )
        if result.marker != nil {
            lastMarkerSavedConfirmation = String(localized: "snorkeling.marker.saved")
            if hapticsEnabled {
                HapticService.shared.confirm()
            }
            showSaveMarker = false
        }
        processHapticCues()
        persistCheckpointSoon()
        refreshPresentation()
    }

    func dismissOverlay(eventID: UUID) {
        dismissedOverlayEventIDs.insert(eventID)
        refreshPresentation()
    }

    func saveCompletedSession(to logbook: SnorkelingLogbookStore) -> Bool {
        var session = engine.snapshot.session
        if session.state != .completed {
            session.state = .completed
        }
        if engine.snapshot.sensorHealth != .available,
           !session.warnings.contains(.dataQualityDegraded) {
            session.warnings.append(.dataQualityDegraded)
        }
        session.statistics = session.refreshedStatistics()
        session.depthSampleSource = activeDepthSensorMetadata.depthSampleSource
        session.depthCapabilityMode = activeDepthSensorMetadata.depthCapabilityMode
        logbook.add(session)
        if logbook.lastSavedSessionID == session.id {
#if os(watchOS)
            sessionSaveState = .syncPending
#else
            sessionSaveState = .saved
#endif
            return true
        }
        sessionSaveState = .failed
        return false
    }

    func resetAfterSave() {
        engine = SnorkelingSessionEngine()
        configureDefaultSession()
        sessionArmed = false
        sessionStarted = false
        showSessionSummary = false
        showSaveMarker = false
        dismissedOverlayEventIDs.removeAll()
        firedHapticKeys.removeAll()
        lastMarkerSavedConfirmation = nil
        isRecoveredSession = false
        checkpointRestoreWarning = nil
        stopSensors()
        stopBackgroundLoops()
        clearCheckpoint()
        refreshPresentation()
    }

    func markSessionSaveFailed() {
        sessionSaveState = .failed
        refreshPresentation()
    }

    func markSessionSyncPending() {
        sessionSaveState = .syncPending
        refreshPresentation()
    }

    #if DEBUG
    func ingestDepthForTesting(depthMeters: Double, temperatureCelsius: Double? = nil, at wallClock: Date = Date()) {
        engine.ingest(
            depthRaw: DepthMeasurementRaw(
                depthMeters: depthMeters,
                sensorTimestamp: wallClock,
                receivedAt: wallClock,
                temperatureCelsius: temperatureCelsius
            ),
            wallClock: wallClock
        )
        processHapticCues()
        refreshPresentation()
    }

    func replaceEngineForTesting(_ engine: SnorkelingSessionEngine, armed: Bool, started: Bool) {
        self.engine = engine
        sessionArmed = armed
        sessionStarted = started
        refreshPresentation()
    }

    func persistCheckpointNowForTesting() {
        persistCheckpoint()
    }
    #endif

    // MARK: - Private

    func reloadImportedRoute() {
        applyImportedRouteIfAvailable()
        refreshPresentation()
    }

    private func configureDefaultSession() {
        engine.configureWatchDefaultsIfNeeded()
        applyImportedRouteIfAvailable()
        engine.setMissionModeEnabled(missionModeEnabled)
        engine.setHapticsEnabled(hapticsEnabled)
        updateBattery()
    }

    private func applyImportedRouteIfAvailable() {
        let store = SnorkelingImportedRouteStore.shared
        guard let plan = store.activeRoutePlan else { return }
        engine.setRoutePlans([plan], activePlanID: plan.id)
        engine.setRoutePlanningMetadata(store.activePlanningMetadata)
        if let metadata = store.activePlanningMetadata {
            let thresholds = SnorkelingOperationalThresholds(
                maxSessionDurationMinutes: Int((metadata.maxSessionDurationSeconds ?? SnorkelingOperationalThresholds.default.maxSessionDurationSeconds) / 60),
                maxDistanceMeters: metadata.maxDistanceMeters ?? SnorkelingOperationalThresholds.default.maxDistanceMeters,
                returnAlertDistanceMeters: SnorkelingOperationalThresholds.default.returnAlertDistanceMeters,
                returnAlertDurationMinutes: SnorkelingOperationalThresholds.default.returnAlertDurationMinutes,
                defaultReturnAlertPolicy: metadata.returnAlertPolicy,
                offRouteThresholdMeters: metadata.offRouteThresholdMeters ?? SnorkelingOperationalThresholds.default.offRouteThresholdMeters,
                gpsQualityWarningAccuracyMeters: metadata.gpsQualityWarningAccuracyMeters ?? SnorkelingOperationalThresholds.default.gpsQualityWarningAccuracyMeters,
                buddyReminderEnabled: metadata.buddyReminderEnabled ?? SnorkelingOperationalThresholds.default.buddyReminderEnabled
            )
            engine.applyOperationalThresholds(thresholds)
            if let buddyEnabled = metadata.buddyReminderEnabled {
                buddyReminderEnabled = buddyEnabled
            }
        }
    }

    private func startSensors() {
        gpsManager?.start()
        compassManager?.start()
        bindGPS()
        bindCompass()
        startDepthSensor()
    }

    private func stopSensors() {
        gpsCancellable?.cancel()
        compassCancellable?.cancel()
        gpsManager?.stop()
        compassManager?.stop()
        stopDepthSensor()
    }

    private func bindGPS() {
        gpsCancellable?.cancel()
        guard let gpsManager else { return }
        gpsCancellable = gpsManager.$lastPoint
            .receive(on: RunLoop.main)
            .sink { [weak self] point in
                self?.handleGPSUpdate(point: point, speed: gpsManager.lastSpeedMetersPerSecond)
            }
    }

    private func bindCompass() {
        compassCancellable?.cancel()
        guard let compassManager else { return }
        compassCancellable = compassManager.$headingDegrees
            .receive(on: RunLoop.main)
            .sink { [weak self] heading in
                self?.handleHeadingUpdate(heading)
            }
    }

    private func handleGPSUpdate(point: GPSPoint?, speed: Double) {
        ingestGPSPoint(point, speed: speed, wallClock: Date())
    }

    private func ingestGPSPoint(_ point: GPSPoint?, speed: Double, wallClock: Date) {
        guard let point else { return }
        let depth = engine.snapshot.currentDepthMeters ?? 0
        let depthRaw = DepthMeasurementRaw(
            depthMeters: depth,
            sensorTimestamp: wallClock,
            receivedAt: wallClock,
            temperatureCelsius: engine.snapshot.currentTemperatureCelsius
        )
        let gpsRaw = SnorkelingGPSRawFix(
            latitude: point.latitude,
            longitude: point.longitude,
            horizontalAccuracyMeters: point.horizontalAccuracy,
            sensorTimestamp: point.timestamp,
            receivedAt: wallClock,
            reportedSpeedMetersPerSecond: speed,
            source: .live
        )
        engine.ingest(depthRaw: depthRaw, gpsRaw: gpsRaw, wallClock: wallClock)
        updateBattery()
        processHapticCues()
        persistCheckpointSoon()
        refreshPresentation()
    }

    private func captureEntrySurfaceFix(at wallClock: Date) {
        guard let gpsManager else { return }
        if let point = gpsManager.currentBestPoint() {
            ingestGPSPoint(point, speed: gpsManager.lastSpeedMetersPerSecond, wallClock: wallClock)
        }
        gpsManager.captureBestEffortPoint(for: 6, stopUpdatesWhenComplete: false) { [weak self] point in
            guard let self, let point else { return }
            self.ingestGPSPoint(point, speed: self.gpsManager?.lastSpeedMetersPerSecond ?? 0, wallClock: Date())
        }
    }

    private func captureExitSurfaceFix(at wallClock: Date) {
        guard let gpsManager else { return }
        if let point = gpsManager.currentBestPoint() {
            ingestGPSPoint(point, speed: gpsManager.lastSpeedMetersPerSecond, wallClock: wallClock)
        }
    }

    private func handleHeadingUpdate(_ heading: Double) {
        let now = Date()
        let age: TimeInterval
        if let last = lastHeadingSample {
            age = now.timeIntervalSince(last.date)
        } else {
            age = 0
        }
        lastHeadingSample = (heading, now)
        engine.updateHeading(degrees: heading, ageSeconds: age)
        refreshPresentation()
    }

    private func startDepthSensor() {
        stopDepthSensor()
        let selection = SensorProviderFactory.makeSelection(mode: SensorSourceMode.runtimeMode)
        activeDepthSensorMetadata = DepthSensorSessionMetadata.capture(from: selection)
        let provider = selection.provider
        provider.onDepthMeasurement = { [weak self] depth, timestamp, temperature in
            Task { @MainActor in
                self?.handleDepthMeasurement(depth: depth, temperature: temperature, timestamp: timestamp)
            }
        }
        provider.start()
        depthProvider = provider
    }

    private func stopDepthSensor() {
        depthProvider?.stop()
        depthProvider = nil
    }

    private func handleDepthMeasurement(depth: Double?, temperature: Double?, timestamp: Date) {
        let now = Date()
        let gpsRaw = gpsManager?.lastPoint.map {
            SnorkelingGPSRawFix(
                latitude: $0.latitude,
                longitude: $0.longitude,
                horizontalAccuracyMeters: $0.horizontalAccuracy,
                sensorTimestamp: $0.timestamp,
                receivedAt: now,
                reportedSpeedMetersPerSecond: gpsManager?.lastSpeedMetersPerSecond,
                source: .live
            )
        }
        engine.ingest(
            depthRaw: DepthMeasurementRaw(
                depthMeters: depth ?? 0,
                sensorTimestamp: timestamp,
                receivedAt: now,
                temperatureCelsius: temperature
            ),
            gpsRaw: gpsRaw,
            wallClock: now
        )
        updateBattery()
        processHapticCues()
        persistCheckpointSoon()
        refreshPresentation()
    }

    private func updateBattery() {
        #if os(watchOS)
        let level = WKInterfaceDevice.current().batteryLevel
        if level >= 0 {
            lastBatteryFraction = Double(level)
            engine.updateBatteryFraction(Double(level))
        }
        #endif
    }

    private func processHapticCues() {
        guard hapticsEnabled else { return }
        for cue in engine.snapshot.pendingHapticCues {
            let key = cue.sourceID ?? UUID()
            guard !firedHapticKeys.contains(key) else { continue }
            firedHapticKeys.insert(key)
            switch cue.pattern {
            case .markerSaved, .waypointReached, .returnAdvised:
                HapticService.shared.confirm()
            case .alarmInfo, .alarmWarning:
                HapticService.shared.notify()
            case .alarmCritical:
                HapticService.shared.criticalConfirm()
            }
        }
    }

    private func startBackgroundLoops() {
        stopBackgroundLoops()
        tickTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self, self.isSessionActive else { continue }
                self.engine.tick()
                self.updateBattery()
                self.processHapticCues()
                self.refreshPresentation()
            }
        }
    }

    private func stopBackgroundLoops() {
        tickTask?.cancel()
        tickTask = nil
        checkpointTask?.cancel()
        checkpointTask = nil
    }

    private func persistCheckpointSoon() {
        checkpointTask?.cancel()
        checkpointTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            self?.persistCheckpoint()
        }
    }

    private func persistCheckpoint() {
        guard sessionArmed || sessionStarted || showSessionSummary else { return }
        let signpost = DIRPerformanceSignpost.begin(.snorkelingRouteCheckpoint)
        defer { signpost.end() }
        do {
            let runtime = SnorkelingCheckpointRuntimeState(
                sessionArmed: sessionArmed,
                sessionStarted: sessionStarted,
                missionModeEnabled: missionModeEnabled,
                hapticsEnabled: hapticsEnabled
            )
            let envelope = try engine.exportCheckpointEnvelope(runtime: runtime)
            let payload = try SnorkelingSessionCheckpointIntegrity.payload(from: envelope)
            let fingerprint = try SnorkelingSessionCheckpointIntegrity.canonicalStateFingerprint(payload: payload)
            if fingerprint == lastCheckpointFingerprint { return }
            lastCheckpointFingerprint = fingerprint
            try SnorkelingSessionCheckpointStore.write(envelope, to: checkpointURL())
            #if DEBUG
            Self.testHook_checkpointWriteCount += 1
            #endif
        } catch {
            // Checkpoint failures must not interrupt an active session.
        }
    }

    @discardableResult
    private func restoreCheckpointIfPresent() -> Bool {
        let currentURL = checkpointURL()
        let previousURL = checkpointPreviousURL()
        guard FileManager.default.fileExists(atPath: currentURL.path)
            || FileManager.default.fileExists(atPath: previousURL.path) else {
            return false
        }
        do {
            let envelope = try SnorkelingSessionCheckpointStore.readWithPreviousFallback(
                currentURL: currentURL,
                previousURL: previousURL
            )
            let restored = try SnorkelingSessionEngine.restoreState(from: envelope)
            engine = restored.engine
            sessionArmed = restored.runtime.sessionArmed
            sessionStarted = restored.runtime.sessionStarted
            missionModeEnabled = restored.runtime.missionModeEnabled
            hapticsEnabled = restored.runtime.hapticsEnabled
            showSessionSummary = engine.snapshot.phase == .ended
            isRecoveredSession = true
            if engine.snapshot.gpsPresentationState == .stale
                || engine.snapshot.gpsPresentationState == .unavailable
                || engine.snapshot.gpsPresentationState == .underwaterUnavailable {
                checkpointRestoreWarning = String(localized: "snorkeling.recovery.gps_degraded")
            }
            if isSessionActive || showSessionSummary {
                startBackgroundLoops()
            }
            return true
        } catch {
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            try? SnorkelingSessionCheckpointStore.quarantineCorruptFile(at: currentURL, baseDirectory: base)
            try? SnorkelingSessionCheckpointStore.quarantineCorruptFile(at: previousURL, baseDirectory: base)
            checkpointRestoreWarning = String(localized: "snorkeling.recovery.checkpoint_failed")
            isRecoveredSession = false
            return false
        }
    }

    private func clearCheckpoint() {
        lastCheckpointFingerprint = nil
        SnorkelingSessionCheckpointStore.clearCheckpointFiles(
            currentURL: checkpointURL(),
            previousURL: checkpointPreviousURL()
        )
    }

    private func checkpointURL() -> URL {
        #if DEBUG
        if let hook = Self.testHook_checkpointURL {
            return hook
        }
        #endif
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(SnorkelingSessionCheckpointStore.checkpointFileName)
    }

    private func checkpointPreviousURL() -> URL {
        #if DEBUG
        if let hook = Self.testHook_checkpointURL {
            return hook.deletingLastPathComponent()
                .appendingPathComponent(SnorkelingSessionCheckpointStore.previousCheckpointFileName)
        }
        #endif
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(SnorkelingSessionCheckpointStore.previousCheckpointFileName)
    }

    private func refreshPresentation() {
        lifecyclePhase = engine.snapshot.phase
        let next = buildPresentationInput()
        guard next != presentationInput else { return }
        presentationInput = next
    }

    private func buildPresentationInput() -> SnorkelingWatchPresentationInput {
        let snapshot = engine.snapshot
        let session = snapshot.session
        let durationAlarm = session.alarms.first { $0.kind == .maxDuration }?.thresholdDurationSeconds
        let distanceAlarm = session.alarms.first { $0.kind == .maxDistance }?.thresholdDistanceMeters
        let activeDipDepths = snapshot.lastDip.map { [$0.maxDepthMeters] } ?? []
        let currentDepth = snapshot.currentDepthMeters ?? 0
        let activeDipMax = max(activeDipDepths.max() ?? 0, currentDepth)
        let underwater = (snapshot.currentDepthMeters ?? 0) >= 0.5
        let entryCaptured = snapshot.returnNavigation.entryPoint != nil || session.entryPoint != nil
        let overlays = snapshot.activeOverlays.filter { !dismissedOverlayEventIDs.contains($0.eventID) }
        let minTemp = session.dips
            .flatMap(\.samples)
            .compactMap(\.temperatureCelsius)
            .min()

        return SnorkelingWatchPresentationInput(
            phase: snapshot.phase,
            isSessionArmed: sessionArmed,
            isSessionStarted: sessionStarted,
            showSessionSummary: showSessionSummary,
            showSaveMarker: showSaveMarker,
            currentDepthMeters: snapshot.currentDepthMeters,
            currentTemperatureCelsius: snapshot.currentTemperatureCelsius,
            verticalSpeedMetersPerSecond: snapshot.verticalSpeedMetersPerSecond,
            sessionElapsedSeconds: snapshot.sessionElapsedSeconds,
            surfaceElapsedSeconds: snapshot.surfaceElapsedSeconds,
            underwaterTimeSeconds: snapshot.underwaterTimeSeconds,
            activeDipElapsedSeconds: snapshot.activeDipElapsedSeconds,
            dipCount: snapshot.dipCount,
            sessionMaxDepthMeters: snapshot.sessionMaxDepthMeters,
            activeDipMaxDepthMeters: activeDipMax,
            accumulatedDistanceMeters: snapshot.accumulatedDistanceMeters,
            averageSpeedMetersPerSecond: averageSpeed(snapshot),
            gpsPresentationState: snapshot.gpsPresentationState,
            depthPresentationState: snapshot.depthPresentationState,
            sensorHealth: snapshot.sensorHealth,
            entryPointCaptured: entryCaptured,
            entryDistanceMeters: snapshot.returnNavigation.distanceToEntryMeters,
            targetDurationSeconds: durationAlarm,
            maxDistanceMeters: distanceAlarm,
            missionModeEnabled: missionModeEnabled,
            hapticsEnabled: hapticsEnabled,
            buddyReminderEnabled: buddyReminderEnabled,
            batteryFraction: lastBatteryFraction,
            markerCount: session.markers.count,
            minimumWaterTemperatureCelsius: minTemp,
            waypointNavigation: snapshot.waypointNavigation,
            returnNavigation: snapshot.returnNavigation,
            activeOverlays: overlays,
            isUnderwater: underwater,
            animationsEnabled: snapshot.missionModePresentationProfile.animationsEnabled,
            selectedMarkerCategory: selectedMarkerCategory,
            markerPositionQualityLabel: markerQualityLabel(for: snapshot),
            markerDistanceFromEntryText: entryDistanceText(snapshot.returnNavigation.distanceToEntryMeters),
            sessionSaveState: sessionSaveState,
            isRecoveredSession: isRecoveredSession,
            recoveryWarning: checkpointRestoreWarning,
            gpsQualityBand: snapshot.gpsQualityBand,
            routeProgressPercent: snapshot.routeProgressPercent,
            offRouteDistanceMeters: snapshot.offRouteDistanceMeters,
            isOffRoute: snapshot.isOffRoute,
            offRouteWarningPaused: snapshot.offRouteWarningPaused,
            plannedReturnAlertActive: snapshot.plannedReturnAlertActive,
            importedRoutePresentation: SnorkelingImportedRouteStore.shared.readyPresentation
        )
    }

    private func averageSpeed(_ snapshot: SnorkelingSessionEngineSnapshot) -> Double {
        guard snapshot.sessionElapsedSeconds > 0 else { return 0 }
        return snapshot.accumulatedDistanceMeters / snapshot.sessionElapsedSeconds
    }

    private func markerQualityLabel(for snapshot: SnorkelingSessionEngineSnapshot) -> String {
        if snapshot.isUnderwaterForPresentation {
            return String(localized: "snorkeling.marker.quality.unavailable")
        }
        switch snapshot.gpsPresentationState {
        case .tracking:
            return String(localized: "snorkeling.marker.quality.measured")
        case .degraded, .stale:
            return String(localized: "snorkeling.marker.quality.degraded")
        default:
            return String(localized: "snorkeling.marker.quality.no_fix")
        }
    }

    private func entryDistanceText(_ meters: Double?) -> String? {
        guard let meters, meters.isFinite else { return nil }
        return "\(Formatters.zero(meters)) m"
    }
}

private extension SnorkelingSessionEngineSnapshot {
    var isUnderwaterForPresentation: Bool {
        (currentDepthMeters ?? 0) >= 0.5
    }
}

extension SnorkelingWatchPresentationInput {
    static let idle = SnorkelingWatchPresentationInput(
        phase: .idle,
        isSessionArmed: false,
        isSessionStarted: false,
        showSessionSummary: false,
        showSaveMarker: false,
        currentDepthMeters: nil,
        currentTemperatureCelsius: nil,
        verticalSpeedMetersPerSecond: 0,
        sessionElapsedSeconds: 0,
        surfaceElapsedSeconds: 0,
        underwaterTimeSeconds: 0,
        activeDipElapsedSeconds: 0,
        dipCount: 0,
        sessionMaxDepthMeters: 0,
        activeDipMaxDepthMeters: 0,
        accumulatedDistanceMeters: 0,
        averageSpeedMetersPerSecond: 0,
        gpsPresentationState: .unavailable,
        depthPresentationState: .unavailable,
        sensorHealth: .available,
        entryPointCaptured: false,
        entryDistanceMeters: nil,
        targetDurationSeconds: nil,
        maxDistanceMeters: nil,
        missionModeEnabled: false,
        hapticsEnabled: true,
        buddyReminderEnabled: false,
        batteryFraction: nil,
        markerCount: 0,
        minimumWaterTemperatureCelsius: nil,
        waypointNavigation: .unavailable,
        returnNavigation: .unavailable,
        activeOverlays: [],
        isUnderwater: false,
        animationsEnabled: true,
        selectedMarkerCategory: .reef,
        markerPositionQualityLabel: "",
        markerDistanceFromEntryText: nil,
        sessionSaveState: .notSaved,
        isRecoveredSession: false,
        recoveryWarning: nil,
        gpsQualityBand: nil,
        routeProgressPercent: nil,
        offRouteDistanceMeters: nil,
        isOffRoute: false,
        offRouteWarningPaused: false,
        plannedReturnAlertActive: false,
        importedRoutePresentation: .missing
    )
}
