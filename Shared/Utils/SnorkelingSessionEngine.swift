import Foundation

struct SnorkelingSessionCheckpoint: Codable, Hashable, Sendable {
    var session: SnorkelingSession
    var lifecyclePhase: SnorkelingLifecyclePhase
    var tracker: SnorkelingLifecycleTracker
    var depthFeedState: SnorkelingDepthFeedState
    var gpsFeedState: SnorkelingGPSFeedState
    var sessionClock: MonotonicElapsedClock.Snapshot
    var dipClock: MonotonicElapsedClock.Snapshot
    var activeDipSamples: [SnorkelingDipSample]
    var activeDipEvents: [SnorkelingEvent]
    var activeDipStartedAtMonotonic: TimeInterval?
    var manualFallbackActive: Bool
    var sensorAvailable: Bool
    var savedAtWallClock: Date
    var savedAtMonotonicSeconds: TimeInterval
    var navigationRuntimeState: SnorkelingNavigationRuntimeState = .initial
    var operationalEventState: SnorkelingOperationalEventState = .initial
}

enum SnorkelingTrackQuality: String, Codable, CaseIterable, Hashable, Sendable {
    case good
    case degraded
    case sparse
    case unavailable
}

enum SnorkelingSensorHealth: String, Codable, CaseIterable, Hashable, Sendable {
    case available
    case degraded
    case manualFallback
}

struct SnorkelingSessionEngineSnapshot: Equatable, Hashable, Sendable {
    var phase: SnorkelingLifecyclePhase
    var session: SnorkelingSession
    var currentDepthMeters: Double?
    var currentTemperatureCelsius: Double?
    var verticalSpeedMetersPerSecond: Double
    var sessionElapsedSeconds: TimeInterval
    var surfaceElapsedSeconds: TimeInterval
    var waterTimeSeconds: TimeInterval
    var underwaterTimeSeconds: TimeInterval
    var activeDipElapsedSeconds: TimeInterval
    var dipCount: Int
    var sessionMaxDepthMeters: Double
    var sessionAverageDepthMeters: Double
    var lastDip: SnorkelingDip?
    var accumulatedDistanceMeters: Double
    var gpsPresentationState: SnorkelingGPSPresentationState
    var depthPresentationState: SnorkelingDepthPresentationState
    var trackQuality: SnorkelingTrackQuality
    var sensorHealth: SnorkelingSensorHealth
    var activeDipSampleCount: Int
    var waypointNavigation: SnorkelingWaypointNavigationSnapshot
    var returnNavigation: SnorkelingReturnNavigationSnapshot
    var activeOverlays: [SnorkelingOperationalOverlay]
    var pendingHapticCues: [SnorkelingHapticCue]
    var missionModePresentationProfile: SnorkelingMissionModePresentationProfile
    var gpsQualityBand: SnorkelingWatchGPSPresentationBand?
    var routeProgressPercent: Double?
    var offRouteDistanceMeters: Double?
    var isOffRoute: Bool
    var offRouteWarningPaused: Bool
    var plannedReturnAlertActive: Bool
}

/// UI-independent snorkeling session engine with shared depth/GPS feeds and dip lifecycle.
struct SnorkelingSessionEngine {
    static let maxPersistedTrackPoints = 50_000

    private(set) var configuration: SnorkelingLifecycleConfiguration
    private(set) var depthFeedConfiguration: SnorkelingDepthFeedConfiguration
    private(set) var gpsFeedConfiguration: SnorkelingGPSFeedConfiguration
    private(set) var snapshot: SnorkelingSessionEngineSnapshot

    private var sessionClock: MonotonicElapsedClock
    private var dipClock: MonotonicElapsedClock
    private var depthFeedState: SnorkelingDepthFeedState
    private var gpsFeedState: SnorkelingGPSFeedState
    private var tracker: SnorkelingLifecycleTracker
    private var session: SnorkelingSession
    private var activeDipSamples: [SnorkelingDipSample]
    private var activeDipEvents: [SnorkelingEvent]
    private var activeDipStartedAtMonotonic: TimeInterval?
    private var manualFallbackActive = false
    private var sensorAvailable = true
    private var sessionArmed = false
    private var sessionStarted = false
    private var pendingManualDipStart = false
    private var pendingManualDipEnd = false
    private var pendingNavigation = false
    private var pendingReturnMode = false
    private var pendingExitNavigation = false
    private var pauseRequested = false
    private var resumeRequested = false
    private var endSessionRequested = false
    private var lastGPSPresentation: SnorkelingGPSPresentationState = .unavailable
    private var lastDepthPresentation: SnorkelingDepthPresentationState = .unavailable
    private var measuredTrackPointCount = 0
    private var navigationRuntime = SnorkelingNavigationRuntimeState.initial
    private var navigationConfiguration = SnorkelingNavigationConfiguration.default
    private var returnAdvisorConfiguration = SnorkelingReturnAdvisorConfiguration.default
    private var headingInput = SnorkelingNavigationHeadingInput(headingDegrees: nil, ageSeconds: nil)
    private var batteryFraction: Double?
    private var lastKnownUnderwater = false
    private var operationalEventState = SnorkelingOperationalEventState.initial
    private var missionModeEnabled = false
    private var hapticsEnabled = true
    private var routePlanningMetadata: SnorkelingRoutePlanningMetadata?
    private var routeCoordinates: [SnorkelingCoordinate] = []
    private var routeRuntimeState = SnorkelingRouteRuntimeState()
    private var gpsQualityThresholds = SnorkelingGPSQualityThresholds.default

    init(
        configuration: SnorkelingLifecycleConfiguration = .default,
        depthFeedConfiguration: SnorkelingDepthFeedConfiguration = .snorkelingDefault,
        gpsFeedConfiguration: SnorkelingGPSFeedConfiguration = .snorkelingDefault,
        sessionStart: Date = Date()
    ) {
        self.configuration = configuration
        self.depthFeedConfiguration = depthFeedConfiguration
        self.gpsFeedConfiguration = gpsFeedConfiguration
        var sessionClock = MonotonicElapsedClock()
        sessionClock.reset(anchorDate: sessionStart)
        self.sessionClock = sessionClock
        self.dipClock = MonotonicElapsedClock()
        self.depthFeedState = .initial
        self.gpsFeedState = .initial
        self.tracker = .initial
        self.session = SnorkelingSession(
            startMode: .watch,
            state: .planned,
            createdAt: sessionStart
        )
        self.activeDipSamples = []
        self.activeDipEvents = []
        self.snapshot = SnorkelingSessionEngine.makePlaceholderSnapshot(session: self.session)
    }

    init(checkpoint: SnorkelingSessionCheckpoint) {
        self.configuration = .default
        self.depthFeedConfiguration = .snorkelingDefault
        self.gpsFeedConfiguration = .snorkelingDefault
        self.sessionClock = MonotonicElapsedClock()
        self.sessionClock.restore(from: checkpoint.sessionClock)
        self.dipClock = MonotonicElapsedClock()
        self.dipClock.restore(from: checkpoint.dipClock)
        self.depthFeedState = checkpoint.depthFeedState
        self.gpsFeedState = checkpoint.gpsFeedState
        self.tracker = checkpoint.tracker
        self.tracker.lastMeasurementMonotonic = nil
        self.session = checkpoint.session
        self.activeDipSamples = checkpoint.activeDipSamples
        self.activeDipEvents = checkpoint.activeDipEvents
        self.activeDipStartedAtMonotonic = checkpoint.activeDipStartedAtMonotonic
        self.manualFallbackActive = checkpoint.manualFallbackActive
        self.sensorAvailable = checkpoint.sensorAvailable
        self.navigationRuntime = checkpoint.navigationRuntimeState
        self.operationalEventState = checkpoint.operationalEventState
        self.sessionArmed = checkpoint.lifecyclePhase != .idle
        self.sessionStarted = checkpoint.lifecyclePhase != .idle && checkpoint.lifecyclePhase != .ready
        self.snapshot = SnorkelingSessionEngine.makePlaceholderSnapshot(session: checkpoint.session, phase: checkpoint.lifecyclePhase)
        refreshSnapshot(
            wallClock: checkpoint.savedAtWallClock,
            uptime: checkpoint.sessionClock.anchorUptime ?? ProcessInfo.processInfo.systemUptime
        )
    }

    mutating func armSession(
        at wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        sessionArmed = true
        runMachine(feedAccepted: false, acceptedDepth: nil, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func startSession(
        at wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        sessionStarted = true
        session.state = .active
        session.startedAtMonotonicSeconds = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        session.events.append(
            SnorkelingEvent(
                kind: .sessionStarted,
                monotonicRelativeTimestampSeconds: session.startedAtMonotonicSeconds ?? 0,
                wallClockTimestamp: wallClock
            )
        )
        runMachine(feedAccepted: depthFeedState.lastAcceptedDepthMeters != nil, acceptedDepth: depthFeedState.lastAcceptedDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime)
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func endSession(
        at wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        endSessionRequested = true
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        let monotonic = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        session.state = .completed
        session.endedAtMonotonicSeconds = monotonic
        session.events.append(
            SnorkelingEvent(
                kind: .sessionEnded,
                monotonicRelativeTimestampSeconds: monotonic,
                wallClockTimestamp: wallClock
            )
        )
        session.statistics = session.refreshedStatistics()
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
        session.runtimeSummary = buildRuntimeSummary()
        snapshot.session = session
    }

    mutating func pauseSession(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        pauseRequested = true
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        session.state = .paused
        pauseRequested = false
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func resumeSession(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        resumeRequested = true
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        session.state = mappedSessionState(for: tracker.phase)
        resumeRequested = false
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func enterNavigation(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        pendingNavigation = true
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        session.state = .navigation
        pendingNavigation = false
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func enterReturnMode(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        pendingReturnMode = true
        SnorkelingReturnAdvisor.activateManualAdvisor(state: &navigationRuntime)
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        session.state = .returnMode
        session.events.append(
            SnorkelingEvent(
                kind: .returnStarted,
                monotonicRelativeTimestampSeconds: sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime),
                wallClockTimestamp: wallClock
            )
        )
        pendingReturnMode = false
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func exitNavigationOrReturn(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        pendingExitNavigation = true
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, uptime: uptime, tickOnly: true)
        session.state = .active
        pendingExitNavigation = false
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
    }

    mutating func setActiveRoutePlan(id: UUID?) {
        session.activeRoutePlanID = id
        if let id, let plan = session.routePlans.first(where: { $0.id == id }) {
            SnorkelingNavigationEngine.reorderRoutePlan(plan, state: &navigationRuntime)
        }
        refreshSnapshot(wallClock: Date())
    }

    mutating func setRoutePlans(_ plans: [SnorkelingRoutePlan], activePlanID: UUID? = nil) {
        session.routePlans = plans
        session.activeRoutePlanID = activePlanID
        if let activePlanID, let plan = plans.first(where: { $0.id == activePlanID }) {
            SnorkelingNavigationEngine.reorderRoutePlan(plan, state: &navigationRuntime)
            routeCoordinates = plan.waypoints
                .sorted { $0.routeOrder < $1.routeOrder }
                .map { SnorkelingCoordinate(latitude: $0.latitude, longitude: $0.longitude) }
        } else {
            routeCoordinates = []
        }
        refreshSnapshot(wallClock: Date())
    }

    mutating func setRoutePlanningMetadata(_ metadata: SnorkelingRoutePlanningMetadata?) {
        routePlanningMetadata = metadata
        if let accuracy = metadata?.gpsQualityWarningAccuracyMeters, accuracy.isFinite, accuracy > 0 {
            gpsQualityThresholds = SnorkelingGPSQualityThresholds(
                goodAccuracyMeters: 15,
                mediumAccuracyMeters: max(15, accuracy),
                goodFixAgeSeconds: 10,
                mediumFixAgeSeconds: 20,
                lostFixAgeSeconds: 60
            )
        }
        refreshSnapshot(wallClock: Date())
    }

    mutating func applyOperationalThresholds(_ thresholds: SnorkelingOperationalThresholds) {
        returnAdvisorConfiguration = SnorkelingReturnAdvisorConfiguration(
            adviseReturnDistanceMeters: thresholds.returnAlertDistanceMeters,
            adviseReturnDurationSeconds: thresholds.returnAlertDurationSeconds,
            adviseReturnBatteryFraction: returnAdvisorConfiguration.adviseReturnBatteryFraction,
            entryReachedRadiusMeters: returnAdvisorConfiguration.entryReachedRadiusMeters,
            alternateSafeTargetMaximumDistanceMeters: returnAdvisorConfiguration.alternateSafeTargetMaximumDistanceMeters
        )
        gpsQualityThresholds = thresholds.gpsQualityThresholds
        upsertAlarm(
            kind: .maxDuration,
            thresholdDurationSeconds: thresholds.maxSessionDurationSeconds,
            thresholdDistanceMeters: nil
        )
        upsertAlarm(
            kind: .maxDistance,
            thresholdDurationSeconds: nil,
            thresholdDistanceMeters: thresholds.maxDistanceMeters
        )
        if var metadata = routePlanningMetadata {
            metadata.offRouteThresholdMeters = thresholds.offRouteThresholdMeters
            metadata.maxSessionDurationSeconds = thresholds.maxSessionDurationSeconds
            metadata.maxDistanceMeters = thresholds.maxDistanceMeters
            metadata.gpsQualityWarningAccuracyMeters = thresholds.gpsQualityWarningAccuracyMeters
            metadata.buddyReminderEnabled = thresholds.buddyReminderEnabled
            routePlanningMetadata = metadata
        }
        refreshSnapshot(wallClock: Date())
    }

    mutating func resetRouteRuntimeTracking() {
        routeRuntimeState = SnorkelingRouteRuntimeState()
    }

    mutating func selectWaypoint(id: UUID) {
        SnorkelingNavigationEngine.selectWaypoint(id: id, state: &navigationRuntime)
        refreshSnapshot(wallClock: Date())
    }

    mutating func skipWaypoint(id: UUID) {
        let plan = activeRoutePlan()
        SnorkelingNavigationEngine.skipWaypoint(id: id, routePlan: plan, state: &navigationRuntime)
        refreshSnapshot(wallClock: Date())
    }

    mutating func overrideEntryPoint(_ entry: SnorkelingEntryPoint) {
        SnorkelingReturnAdvisor.overrideEntryPoint(entry, state: &navigationRuntime)
        if SnorkelingDomainSupport.isValidCoordinate(latitude: entry.latitude, longitude: entry.longitude) {
            session.entryPoint = SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: entry.monotonicRelativeTimestampSeconds,
                wallClockTimestamp: entry.capturedAt,
                latitude: entry.latitude,
                longitude: entry.longitude,
                horizontalAccuracyMeters: entry.horizontalAccuracyMeters,
                gpsQuality: entry.gpsQuality,
                isUnderwater: false
            )
        }
        refreshSnapshot(wallClock: Date())
    }

    mutating func setAlternateReturnTarget(_ target: SnorkelingEntryPoint?) {
        SnorkelingReturnAdvisor.setAlternateSafeTarget(target, state: &navigationRuntime)
        refreshSnapshot(wallClock: Date())
    }

    mutating func updateHeading(degrees: Double?, ageSeconds: TimeInterval?) {
        headingInput = SnorkelingNavigationHeadingInput(headingDegrees: degrees, ageSeconds: ageSeconds)
        refreshSnapshot(wallClock: Date())
    }

    mutating func updateBatteryFraction(_ fraction: Double?) {
        batteryFraction = fraction
        refreshSnapshot(wallClock: Date())
    }

    mutating func setMissionModeEnabled(_ enabled: Bool) {
        missionModeEnabled = enabled
        refreshSnapshot(wallClock: Date())
    }

    mutating func setHapticsEnabled(_ enabled: Bool) {
        hapticsEnabled = enabled
        refreshSnapshot(wallClock: Date())
    }

    mutating func configureWatchDefaultsIfNeeded() {
        guard session.alarms.isEmpty else { return }
        let defaults = SnorkelingOperationalThresholds.default
        session.alarms = [
            SnorkelingAlarm(kind: .maxDepth, label: "Depth", thresholdDepthMeters: 10),
            SnorkelingAlarm(kind: .maxDuration, label: "Duration", thresholdDurationSeconds: defaults.maxSessionDurationSeconds),
            SnorkelingAlarm(kind: .maxDistance, label: "Distance", thresholdDistanceMeters: defaults.maxDistanceMeters)
        ]
        if session.buddy == nil {
            session.buddy = SnorkelingBuddyInfo(isBuddyPresent: false)
        }
        applyOperationalThresholds(defaults)
    }

    private mutating func upsertAlarm(
        kind: SnorkelingAlarmKind,
        thresholdDurationSeconds: TimeInterval?,
        thresholdDistanceMeters: Double?
    ) {
        if let index = session.alarms.firstIndex(where: { $0.kind == kind }) {
            if let thresholdDurationSeconds {
                session.alarms[index].thresholdDurationSeconds = thresholdDurationSeconds
            }
            if let thresholdDistanceMeters {
                session.alarms[index].thresholdDistanceMeters = thresholdDistanceMeters
            }
            return
        }
        switch kind {
        case .maxDuration:
            session.alarms.append(
                SnorkelingAlarm(
                    kind: .maxDuration,
                    label: "Duration",
                    thresholdDurationSeconds: thresholdDurationSeconds ?? SnorkelingOperationalThresholds.default.maxSessionDurationSeconds
                )
            )
        case .maxDistance:
            session.alarms.append(
                SnorkelingAlarm(
                    kind: .maxDistance,
                    label: "Distance",
                    thresholdDistanceMeters: thresholdDistanceMeters ?? SnorkelingOperationalThresholds.default.maxDistanceMeters
                )
            )
        default:
            break
        }
    }

    @discardableResult
    mutating func saveMarker(
        request: SnorkelingMarkerCaptureRequest,
        at wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> SnorkelingMarkerCaptureResult {
        let monotonic = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        let result = SnorkelingMarkerCaptureEngine.capture(
            request: request,
            monotonicNow: monotonic,
            wallClockNow: wallClock,
            sessionID: session.id,
            depthMeters: depthFeedState.lastAcceptedDepthMeters,
            temperatureCelsius: depthFeedState.lastTemperatureCelsius,
            headingDegrees: headingInput.headingDegrees,
            isUnderwater: lastKnownUnderwater,
            gpsAcceptedFix: gpsFeedState.lastAcceptedFix,
            gpsPresentationState: lastGPSPresentation,
            entryPoint: navigationRuntime.entryPoint ?? session.entryPoint.flatMap(entryPoint(from:)),
            hapticsEnabled: hapticsEnabled,
            missionModeEnabled: missionModeEnabled
        )
        if let marker = result.marker, let event = result.event {
            session.markers.append(marker)
            session.events.append(event)
            session.statistics = session.refreshedStatistics()
        }
        refreshSnapshot(wallClock: wallClock, uptime: uptime)
        return result
    }

    mutating func enableManualFallback() {
        manualFallbackActive = true
        sensorAvailable = false
        refreshSnapshot(wallClock: Date())
    }

    mutating func disableManualFallback() {
        manualFallbackActive = false
        sensorAvailable = true
        refreshSnapshot(wallClock: Date())
    }

    mutating func triggerManualDipStart(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        guard manualFallbackActive else { return }
        pendingManualDipStart = true
        ingestDepthOnly(
            raw: DepthMeasurementRaw(
                depthMeters: max(depthFeedState.lastAcceptedDepthMeters ?? configuration.dipStartDepthMeters + 0.2, configuration.dipStartDepthMeters + 0.2),
                sensorTimestamp: wallClock,
                receivedAt: wallClock
            ),
            wallClock: wallClock,
            uptime: uptime
        )
        pendingManualDipStart = false
    }

    mutating func triggerManualDipEnd(at wallClock: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        guard manualFallbackActive else { return }
        pendingManualDipEnd = true
        ingestDepthOnly(
            raw: DepthMeasurementRaw(
                depthMeters: 0,
                sensorTimestamp: wallClock,
                receivedAt: wallClock
            ),
            wallClock: wallClock,
            uptime: uptime
        )
        pendingManualDipEnd = false
    }

    @discardableResult
    mutating func ingest(
        depthRaw: DepthMeasurementRaw,
        gpsRaw: SnorkelingGPSRawFix? = nil,
        wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> (depth: SnorkelingDepthIngestResult, gps: SnorkelingGPSIngestResult?) {
        let monotonic = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        let depthResult = SnorkelingDepthFeed.ingest(
            raw: depthRaw,
            monotonicRelativeTimestampSeconds: monotonic,
            state: &depthFeedState,
            configuration: depthFeedConfiguration
        )
        lastDepthPresentation = depthResult.presentationState
        lastKnownUnderwater = depthResult.isUnderwater

        var gpsResult: SnorkelingGPSIngestResult?
        if let gpsRaw {
            gpsResult = SnorkelingGPSFeed.ingest(
                raw: gpsRaw,
                monotonicRelativeTimestampSeconds: monotonic,
                isUnderwater: depthResult.isUnderwater,
                state: &gpsFeedState,
                configuration: gpsFeedConfiguration,
                now: wallClock
            )
            lastGPSPresentation = gpsResult?.presentationState ?? .unavailable
            appendTrackPoint(from: gpsResult, depthResult: depthResult, monotonic: monotonic, wallClock: wallClock)
        }

        if let accepted = depthResult.acceptedDepthMeters, depthResult.depthFeedQuality == .accepted {
            sensorAvailable = true
            runMachine(
                feedAccepted: true,
                acceptedDepth: accepted,
                verticalSpeed: depthResult.verticalSpeedMetersPerSecond ?? 0,
                wallClock: wallClock,
                uptime: uptime
            )
            appendAcceptedDipSample(from: depthResult, wallClock: wallClock, uptime: uptime)
        } else {
            if depthResult.depthFeedQuality == .missing {
                sensorAvailable = false
            }
            runMachine(
                feedAccepted: false,
                acceptedDepth: depthResult.acceptedDepthMeters,
                verticalSpeed: 0,
                wallClock: wallClock,
                uptime: uptime
            )
        }

        refreshSnapshot(wallClock: wallClock, uptime: uptime)
        return (depthResult, gpsResult)
    }

    mutating func ingestDepthOnly(
        raw: DepthMeasurementRaw,
        wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        _ = ingest(depthRaw: raw, gpsRaw: nil, wallClock: wallClock, uptime: uptime)
    }

    mutating func tick(
        now: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        runMachine(
            feedAccepted: false,
            acceptedDepth: snapshot.currentDepthMeters,
            verticalSpeed: 0,
            wallClock: now,
            uptime: uptime,
            tickOnly: true
        )
        refreshSnapshot(wallClock: now, uptime: uptime)
    }

    mutating func exportCheckpoint(now: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) -> SnorkelingSessionCheckpoint {
        var elapsedClock = MonotonicElapsedClock()
        elapsedClock.restore(from: sessionClock.exportSnapshot())
        let savedMonotonic = elapsedClock.elapsed(now: now, uptime: uptime)
        return SnorkelingSessionCheckpoint(
            session: session,
            lifecyclePhase: tracker.phase,
            tracker: tracker,
            depthFeedState: depthFeedState,
            gpsFeedState: gpsFeedState,
            sessionClock: sessionClock.exportSnapshot(),
            dipClock: dipClock.exportSnapshot(),
            activeDipSamples: activeDipSamples,
            activeDipEvents: activeDipEvents,
            activeDipStartedAtMonotonic: activeDipStartedAtMonotonic,
            manualFallbackActive: manualFallbackActive,
            sensorAvailable: sensorAvailable,
            savedAtWallClock: now,
            savedAtMonotonicSeconds: savedMonotonic,
            navigationRuntimeState: navigationRuntime,
            operationalEventState: operationalEventState
        )
    }

    // MARK: - Private

    private mutating func runMachine(
        feedAccepted: Bool,
        acceptedDepth: Double?,
        verticalSpeed: Double,
        wallClock: Date,
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime,
        tickOnly: Bool = false
    ) {
        let monotonicNow = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        let input = SnorkelingLifecycleMachineInput(
            configuration: configuration,
            monotonicNow: monotonicNow,
            wallClockNow: wallClock,
            acceptedDepthMeters: acceptedDepth,
            verticalSpeedMetersPerSecond: verticalSpeed,
            feedAccepted: feedAccepted,
            sensorAvailable: sensorAvailable,
            manualFallbackActive: manualFallbackActive,
            manualDipStartTriggered: pendingManualDipStart,
            manualDipEndTriggered: pendingManualDipEnd,
            sessionArmed: sessionArmed,
            sessionStarted: sessionStarted,
            navigationRequested: pendingNavigation,
            returnModeRequested: pendingReturnMode,
            exitNavigationRequested: pendingExitNavigation,
            pauseRequested: pauseRequested,
            resumeRequested: resumeRequested,
            endSessionRequested: endSessionRequested,
            tickOnly: tickOnly
        )
        let output = SnorkelingLifecycleStateMachine.evaluate(input: input, tracker: tracker)
        tracker = output.tracker
        applyTransitionEvents(output.events, wallClock: wallClock, uptime: uptime)
        session.state = mappedSessionState(for: tracker.phase)
    }

    private mutating func applyTransitionEvents(
        _ events: [SnorkelingLifecycleTransitionEvent],
        wallClock: Date,
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        let monotonic = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        for event in events {
            switch event {
            case .phaseChanged:
                break
            case .dipStarted(let atMonotonic):
                activeDipStartedAtMonotonic = atMonotonic
                dipClock.reset(anchorDate: wallClock, uptime: uptime)
                activeDipSamples = []
                activeDipEvents = [
                    SnorkelingEvent(
                        kind: .dipStarted,
                        monotonicRelativeTimestampSeconds: atMonotonic,
                        wallClockTimestamp: wallClock
                    )
                ]
            case .dipEnded(let atMonotonic, let startedAt, let maxDepth):
                finalizeActiveDip(endedAtMonotonic: atMonotonic, startedAtMonotonic: startedAt, maxDepthMeters: maxDepth, wallClock: wallClock)
            case .sensorDegraded:
                session.warnings.append(.dataQualityDegraded)
                session.events.append(
                    SnorkelingEvent(
                        kind: .depthUnavailable,
                        monotonicRelativeTimestampSeconds: monotonic,
                        wallClockTimestamp: wallClock
                    )
                )
            case .sensorRecovered:
                session.events.append(
                    SnorkelingEvent(
                        kind: .gpsRecovered,
                        monotonicRelativeTimestampSeconds: monotonic,
                        wallClockTimestamp: wallClock
                    )
                )
            case .sessionAutoEnded:
                endSession(at: wallClock, uptime: uptime)
            }
        }
    }

    private mutating func finalizeActiveDip(
        endedAtMonotonic: TimeInterval,
        startedAtMonotonic: TimeInterval,
        maxDepthMeters: Double,
        wallClock: Date
    ) {
        let duration = max(0, endedAtMonotonic - startedAtMonotonic)
        let metrics = SnorkelingDomainSupport.depthMetrics(from: activeDipSamples)
        var dip = SnorkelingDip(
            startedAtMonotonicSeconds: startedAtMonotonic,
            endedAtMonotonicSeconds: endedAtMonotonic,
            startedAtWallClock: wallClock.addingTimeInterval(-duration),
            endedAtWallClock: wallClock,
            durationSeconds: duration,
            maxDepthMeters: max(maxDepthMeters, metrics.maxDepthMeters),
            averageDepthMeters: metrics.averageDepthMeters,
            samples: activeDipSamples,
            events: activeDipEvents
        )
        dip.events.append(
            SnorkelingEvent(
                kind: .dipEnded,
                monotonicRelativeTimestampSeconds: endedAtMonotonic,
                wallClockTimestamp: wallClock,
                depthMeters: dip.maxDepthMeters,
                relatedDipID: dip.id
            )
        )
        session.dips.append(dip)
        session.events.append(dip.events.last!)
        session.statistics = session.refreshedStatistics()
        activeDipStartedAtMonotonic = nil
        activeDipSamples = []
        activeDipEvents = []
        dipClock.clear()
    }

    private mutating func appendAcceptedDipSample(
        from result: SnorkelingDepthIngestResult,
        wallClock: Date,
        uptime: TimeInterval
    ) {
        guard activeDipStartedAtMonotonic != nil, let depth = result.acceptedDepthMeters else { return }
        let dipElapsed = dipClock.elapsed(now: wallClock, uptime: uptime)
        activeDipSamples.append(
            SnorkelingDipSample(
                monotonicRelativeTimestampSeconds: dipElapsed,
                wallClockTimestamp: result.raw.sensorTimestamp,
                depthMeters: depth,
                temperatureCelsius: result.temperatureCelsius,
                verticalSpeedMetersPerSecond: result.verticalSpeedMetersPerSecond ?? 0,
                depthQuality: result.snorkelingQuality
            )
        )
    }

    private mutating func appendTrackPoint(
        from gpsResult: SnorkelingGPSIngestResult?,
        depthResult: SnorkelingDepthIngestResult,
        monotonic: TimeInterval,
        wallClock: Date
    ) {
        guard let gpsResult else { return }
        if gpsResult.gpsQuality == .measured {
            measuredTrackPointCount += 1
        }
        let accepted = gpsResult.accepted
        session.trackPoints.append(
            SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: monotonic,
                wallClockTimestamp: wallClock,
                latitude: accepted?.latitude,
                longitude: accepted?.longitude,
                horizontalAccuracyMeters: accepted?.horizontalAccuracyMeters,
                gpsQuality: gpsResult.gpsQuality,
                depthMeters: depthResult.acceptedDepthMeters,
                depthQuality: depthResult.snorkelingQuality,
                isUnderwater: depthResult.isUnderwater
            )
        )
        if session.trackPoints.count > Self.maxPersistedTrackPoints {
            session.trackPoints = SnorkelingRoutePresentationSampling.downsampleTrackPointsForPresentation(
                session.trackPoints,
                maxPoints: Self.maxPersistedTrackPoints
            )
        }
        if session.entryPoint == nil, gpsResult.gpsQuality == .measured, let accepted {
            session.entryPoint = SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: monotonic,
                wallClockTimestamp: wallClock,
                latitude: accepted.latitude,
                longitude: accepted.longitude,
                horizontalAccuracyMeters: accepted.horizontalAccuracyMeters,
                gpsQuality: .measured,
                depthMeters: depthResult.acceptedDepthMeters,
                depthQuality: depthResult.snorkelingQuality,
                isUnderwater: false
            )
            SnorkelingReturnAdvisor.captureEntryPointIfNeeded(
                from: accepted,
                capturedAt: wallClock,
                isUnderwater: false,
                state: &navigationRuntime
            )
        }
        if gpsResult.rejectionReason == .underwater {
            session.warnings.append(.estimatedPositionUsed)
        }
    }

    private mutating func sessionMonotonicElapsed(
        wallClock: Date,
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> TimeInterval {
        sessionClock.elapsed(now: wallClock, uptime: uptime)
    }

    private func mappedSessionState(for phase: SnorkelingLifecyclePhase) -> SnorkelingSessionState {
        switch phase {
        case .idle, .ready:
            return .planned
        case .paused:
            return .paused
        case .navigation:
            return .navigation
        case .returnMode:
            return .returnMode
        case .ended:
            return .completed
        default:
            return .active
        }
    }

    private mutating func refreshSnapshot(
        wallClock: Date,
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        let sessionElapsed = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        let dipElapsed = activeDipStartedAtMonotonic == nil ? 0 : dipClock.elapsed(now: wallClock, uptime: uptime)
        var underwater = tracker.totalUnderwaterSeconds
        if let started = tracker.lastUnderwaterPhaseStart {
            underwater += max(0, sessionElapsed - started)
        }
        let surfaceElapsed = max(0, sessionElapsed - underwater)
        let allDepths = session.dips.flatMap(\.samples).map(\.depthMeters) + activeDipSamples.map(\.depthMeters)
        let averageDepth = allDepths.isEmpty ? 0 : allDepths.reduce(0, +) / Double(allDepths.count)
        let health: SnorkelingSensorHealth
        if manualFallbackActive {
            health = .manualFallback
        } else if tracker.phase == .sensorDegraded {
            health = .degraded
        } else {
            health = .available
        }

        updateNavigationRuntime(wallClock: wallClock, uptime: uptime)
        let presentationProfile = missionModeEnabled ? SnorkelingMissionModePresentationProfile.mission : .standard
        let operational = evaluateOperationalEvents(
            wallClock: wallClock,
            sessionElapsed: sessionElapsed,
            dipElapsed: dipElapsed,
            health: health
        )
        session.events.append(contentsOf: operational.events)

        let currentCoordinate = gpsFeedState.lastAcceptedFix.map {
            SnorkelingCoordinate(latitude: $0.latitude, longitude: $0.longitude)
        }
        let fixAge = gpsFeedState.lastAcceptedFix?.fixAgeSeconds
        let routeRuntime = SnorkelingRouteRuntimeEvaluator.evaluate(
            metadata: routePlanningMetadata,
            routeCoordinates: routeCoordinates,
            currentCoordinate: currentCoordinate,
            horizontalAccuracyMeters: gpsFeedState.lastAcceptedFix?.horizontalAccuracyMeters,
            fixAgeSeconds: fixAge,
            sessionElapsedSeconds: sessionElapsed,
            traveledDistanceMeters: gpsFeedState.accumulatedDistanceMeters,
            monotonicNow: sessionElapsed,
            state: &routeRuntimeState
        )
        var hapticCues = operational.hapticCues
        hapticCues.append(contentsOf: routeRuntime.hapticCues)

        snapshot = SnorkelingSessionEngineSnapshot(
            phase: tracker.phase,
            session: session,
            currentDepthMeters: depthFeedState.lastAcceptedDepthMeters,
            currentTemperatureCelsius: depthFeedState.lastTemperatureCelsius,
            verticalSpeedMetersPerSecond: depthFeedState.depthFeedState.lastAccepted?.verticalSpeedMetersPerSecond ?? 0,
            sessionElapsedSeconds: sessionElapsed,
            surfaceElapsedSeconds: surfaceElapsed,
            waterTimeSeconds: underwater,
            underwaterTimeSeconds: underwater,
            activeDipElapsedSeconds: dipElapsed,
            dipCount: session.dips.count,
            sessionMaxDepthMeters: session.statistics.sessionMaxDepthMeters,
            sessionAverageDepthMeters: averageDepth,
            lastDip: session.dips.last,
            accumulatedDistanceMeters: gpsFeedState.accumulatedDistanceMeters,
            gpsPresentationState: lastGPSPresentation,
            depthPresentationState: lastDepthPresentation,
            trackQuality: trackQuality(for: lastGPSPresentation),
            sensorHealth: health,
            activeDipSampleCount: activeDipSamples.count,
            waypointNavigation: navigationRuntime.lastWaypointNavigation,
            returnNavigation: navigationRuntime.lastReturnNavigation,
            activeOverlays: operational.overlays,
            pendingHapticCues: hapticCues,
            missionModePresentationProfile: presentationProfile,
            gpsQualityBand: routeRuntime.gpsQualityBand,
            routeProgressPercent: routeRuntime.routeProgressPercent,
            offRouteDistanceMeters: routeRuntime.offRouteDistanceMeters,
            isOffRoute: routeRuntime.isOffRoute,
            offRouteWarningPaused: routeRuntime.offRouteWarningPaused,
            plannedReturnAlertActive: routeRuntime.plannedReturnAlertTriggered || routeRuntimeState.returnAlertTriggered
        )
    }

    private func buildRuntimeSummary() -> SnorkelingSessionRuntimeSummary {
        SnorkelingRouteRuntimeEvaluator.makeRuntimeSummary(
            state: routeRuntimeState,
            gpsQualityBand: snapshot.gpsQualityBand,
            routeProgressPercent: snapshot.routeProgressPercent,
            trackPointCount: session.trackPoints.count
        )
    }

    private mutating func evaluateOperationalEvents(
        wallClock: Date,
        sessionElapsed: TimeInterval,
        dipElapsed: TimeInterval,
        health: SnorkelingSensorHealth
    ) -> SnorkelingOperationalEventOutput {
        let distanceFromEntry: Double?
        if let entry = navigationRuntime.entryPoint ?? session.entryPoint.flatMap(entryPoint(from:)),
           let fix = gpsFeedState.lastAcceptedFix {
            distanceFromEntry = SnorkelingDomainSupport.distanceMeters(
                from: (latitude: entry.latitude, longitude: entry.longitude),
                to: (latitude: fix.latitude, longitude: fix.longitude)
            )
        } else {
            distanceFromEntry = nil
        }
        let context = SnorkelingOperationalEventContext(
            monotonicNow: sessionElapsed,
            wallClockNow: wallClock,
            sessionElapsedSeconds: sessionElapsed,
            activeDipElapsedSeconds: dipElapsed,
            distanceFromEntryMeters: distanceFromEntry,
            batteryFraction: batteryFraction,
            temperatureCelsius: depthFeedState.lastTemperatureCelsius,
            gpsPresentationState: lastGPSPresentation,
            sensorHealth: health,
            missionModeEnabled: missionModeEnabled,
            hapticsEnabled: hapticsEnabled
        )
        return SnorkelingOperationalEventEngine.evaluate(
            alarms: session.alarms,
            depthMeters: depthFeedState.lastAcceptedDepthMeters,
            verticalSpeedMetersPerSecond: depthFeedState.depthFeedState.lastAccepted?.verticalSpeedMetersPerSecond ?? 0,
            state: &operationalEventState,
            context: context
        )
    }

    private func entryPoint(from trackPoint: SnorkelingTrackPoint) -> SnorkelingEntryPoint? {
        guard let latitude = trackPoint.latitude, let longitude = trackPoint.longitude else { return nil }
        return SnorkelingEntryPoint(
            latitude: latitude,
            longitude: longitude,
            capturedAt: trackPoint.wallClockTimestamp ?? Date(),
            monotonicRelativeTimestampSeconds: trackPoint.monotonicRelativeTimestampSeconds,
            gpsQuality: trackPoint.gpsQuality,
            horizontalAccuracyMeters: trackPoint.horizontalAccuracyMeters
        )
    }

    private mutating func updateNavigationRuntime(
        wallClock: Date,
        uptime: TimeInterval
    ) {
        syncEntryPointFromSessionIfNeeded()
        let position = navigationPositionInput()
        let routePlan = activeRoutePlan()
        let sessionElapsed = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)

        switch tracker.phase {
        case .navigation:
            let previousCompleted = Set(navigationRuntime.completedWaypointIDs)
            let (_, updated) = SnorkelingNavigationEngine.evaluateWaypointNavigation(
                routePlan: routePlan,
                state: navigationRuntime,
                position: position,
                heading: headingInput,
                configuration: navigationConfiguration
            )
            navigationRuntime = updated
            let newlyCompleted = Set(updated.completedWaypointIDs).subtracting(previousCompleted)
            if !newlyCompleted.isEmpty {
                for waypointID in newlyCompleted {
                    guard let waypoint = routePlan?.waypoints.first(where: { $0.id == waypointID }) else { continue }
                    session.events.append(
                        SnorkelingEvent(
                            kind: .waypointReached,
                            monotonicRelativeTimestampSeconds: sessionElapsed,
                            wallClockTimestamp: wallClock,
                            latitude: position.latitude,
                            longitude: position.longitude,
                            note: waypoint.name,
                            relatedWaypointID: waypointID
                        )
                    )
                }
            }
        case .returnMode:
            let (_, updated) = SnorkelingReturnAdvisor.evaluateReturnNavigation(
                state: navigationRuntime,
                position: position,
                heading: headingInput,
                sessionElapsedSeconds: sessionElapsed,
                batteryFraction: batteryFraction,
                now: wallClock,
                configuration: returnAdvisorConfiguration,
                navigationConfiguration: navigationConfiguration
            )
            navigationRuntime = updated
        default:
            break
        }
    }

    private func activeRoutePlan() -> SnorkelingRoutePlan? {
        guard let id = session.activeRoutePlanID else { return nil }
        return session.routePlans.first(where: { $0.id == id })
    }

    func presentationRouteCoordinates() -> [SnorkelingCoordinate] {
        routeCoordinates
    }

    func currentAcceptedSurfaceCoordinate() -> SnorkelingCoordinate? {
        guard let fix = gpsFeedState.lastAcceptedFix,
              fix.gpsQuality.isMeasuredSurfaceFix,
              SnorkelingDomainSupport.isValidCoordinate(latitude: fix.latitude, longitude: fix.longitude) else {
            return nil
        }
        return SnorkelingCoordinate(latitude: fix.latitude, longitude: fix.longitude)
    }

    private mutating func syncEntryPointFromSessionIfNeeded() {
        guard navigationRuntime.entryPoint == nil,
              let entry = session.entryPoint,
              let latitude = entry.latitude,
              let longitude = entry.longitude else {
            return
        }
        navigationRuntime.entryPoint = SnorkelingEntryPoint(
            latitude: latitude,
            longitude: longitude,
            capturedAt: entry.wallClockTimestamp ?? Date(),
            monotonicRelativeTimestampSeconds: entry.monotonicRelativeTimestampSeconds,
            gpsQuality: entry.gpsQuality,
            horizontalAccuracyMeters: entry.horizontalAccuracyMeters
        )
    }

    private func navigationPositionInput() -> SnorkelingNavigationPositionInput {
        let accepted = gpsFeedState.lastAcceptedFix
        return SnorkelingNavigationPositionInput(
            latitude: accepted?.latitude,
            longitude: accepted?.longitude,
            gpsQuality: accepted?.gpsQuality ?? .unavailable,
            gpsPresentationState: lastGPSPresentation,
            isUnderwater: lastKnownUnderwater,
            surfaceSpeedMetersPerSecond: accepted?.impliedSpeedMetersPerSecond,
            fixAgeSeconds: accepted?.fixAgeSeconds
        )
    }

    private func trackQuality(for gpsPresentation: SnorkelingGPSPresentationState) -> SnorkelingTrackQuality {
        switch gpsPresentation {
        case .tracking:
            return measuredTrackPointCount >= 2 ? .good : .sparse
        case .degraded, .stale:
            return .degraded
        case .unavailable, .underwaterUnavailable:
            return measuredTrackPointCount > 0 ? .sparse : .unavailable
        }
    }

    private static func makePlaceholderSnapshot(
        session: SnorkelingSession,
        phase: SnorkelingLifecyclePhase = .idle
    ) -> SnorkelingSessionEngineSnapshot {
        SnorkelingSessionEngineSnapshot(
            phase: phase,
            session: session,
            currentDepthMeters: nil,
            currentTemperatureCelsius: nil,
            verticalSpeedMetersPerSecond: 0,
            sessionElapsedSeconds: 0,
            surfaceElapsedSeconds: 0,
            waterTimeSeconds: 0,
            underwaterTimeSeconds: 0,
            activeDipElapsedSeconds: 0,
            dipCount: 0,
            sessionMaxDepthMeters: 0,
            sessionAverageDepthMeters: 0,
            lastDip: nil,
            accumulatedDistanceMeters: 0,
            gpsPresentationState: .unavailable,
            depthPresentationState: .unavailable,
            trackQuality: .unavailable,
            sensorHealth: .available,
            activeDipSampleCount: 0,
            waypointNavigation: .unavailable,
            returnNavigation: .unavailable,
            activeOverlays: [],
            pendingHapticCues: [],
            missionModePresentationProfile: .standard,
            gpsQualityBand: nil,
            routeProgressPercent: nil,
            offRouteDistanceMeters: nil,
            isOffRoute: false,
            offRouteWarningPaused: false,
            plannedReturnAlertActive: false
        )
    }
}
