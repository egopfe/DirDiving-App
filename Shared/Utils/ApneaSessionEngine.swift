import Foundation

enum ApneaSensorHealth: String, Codable, Hashable, Sendable {
    case available
    case degraded
    case manualFallback
}

struct ApneaSessionEngineSnapshot: Equatable, Hashable, Sendable {
    var phase: ApneaLifecyclePhase
    var session: ApneaSession
    var currentDepthMeters: Double?
    var verticalSpeedMetersPerSecond: Double
    var diveElapsedSeconds: TimeInterval
    var surfaceElapsedSeconds: TimeInterval
    var sessionElapsedSeconds: TimeInterval
    var totalUnderwaterSeconds: TimeInterval
    var requiredRecoverySeconds: TimeInterval
    var recoveryElapsedSeconds: TimeInterval
    var recoveryRemainingSeconds: TimeInterval?
    var isRecoveryComplete: Bool
    var sensorHealth: ApneaSensorHealth
    var rawSampleCount: Int
    var acceptedSampleCount: Int
    var activeDiveSampleCount: Int
}

/// UI-independent Apnea session engine with shared depth feed and lifecycle state machine.
struct ApneaSessionEngine {
    private(set) var configuration: ApneaLifecycleConfiguration
    private(set) var feedConfiguration: DepthMeasurementFeedConfiguration
    private(set) var recoveryPolicy: ApneaRecoveryPolicy
    private(set) var snapshot: ApneaSessionEngineSnapshot

    private var sessionClock: MonotonicElapsedClock
    private var diveClock: MonotonicElapsedClock
    private var feedState: DepthMeasurementFeedState
    private var tracker: ApneaLifecycleTracker
    private var session: ApneaSession
    private var rawSamples: [ApneaSample]
    private var activeDiveAcceptedSamples: [ApneaSample]
    private var activeDiveEvents: [ApneaEvent]
    private var activeDiveStartedAtMonotonic: TimeInterval?
    private var currentRecoveryInterval: ApneaRecoveryInterval?
    private var lastDiveDurationSeconds: TimeInterval = 0
    private var manualFallbackActive = false
    private var sensorAvailable = true
    private var sessionArmed = false
    private var pendingManualDescent = false
    private var pendingManualSurface = false
    private var endSessionRequested = false

    init(
        configuration: ApneaLifecycleConfiguration = .default,
        feedConfiguration: DepthMeasurementFeedConfiguration = .apneaDefault,
        recoveryPolicy: ApneaRecoveryPolicy = .default,
        sessionStart: Date = Date()
    ) {
        self.configuration = configuration
        self.feedConfiguration = feedConfiguration
        self.recoveryPolicy = recoveryPolicy
        var sessionClock = MonotonicElapsedClock()
        sessionClock.reset(anchorDate: sessionStart)
        self.sessionClock = sessionClock
        self.diveClock = MonotonicElapsedClock()
        self.feedState = .initial
        self.tracker = .initial
        self.session = ApneaSession(
            startMode: .watch,
            state: .planned,
            createdAt: sessionStart,
            startedAtMonotonicSeconds: 0
        )
        self.rawSamples = []
        self.activeDiveAcceptedSamples = []
        self.activeDiveEvents = []
        self.snapshot = ApneaSessionEngineSnapshot(
            phase: .idle,
            session: self.session,
            currentDepthMeters: nil,
            verticalSpeedMetersPerSecond: 0,
            diveElapsedSeconds: 0,
            surfaceElapsedSeconds: 0,
            sessionElapsedSeconds: 0,
            totalUnderwaterSeconds: 0,
            requiredRecoverySeconds: 0,
            recoveryElapsedSeconds: 0,
            recoveryRemainingSeconds: nil,
            isRecoveryComplete: true,
            sensorHealth: .available,
            rawSampleCount: 0,
            acceptedSampleCount: 0,
            activeDiveSampleCount: 0
        )
    }

    init(checkpoint envelope: ApneaSessionCheckpointEnvelope) throws {
        let payload = try ApneaSessionCheckpointIntegrity.payload(from: envelope)
        self.configuration = .default
        self.feedConfiguration = .apneaDefault
        self.recoveryPolicy = payload.session.profile?.preferredRecoveryPolicy ?? .default
        self.sessionClock = MonotonicElapsedClock()
        self.sessionClock.restore(from: payload.sessionClock)
        self.diveClock = MonotonicElapsedClock()
        self.diveClock.restore(from: payload.diveClock)
        self.feedState = payload.feedState
        self.tracker = payload.tracker
        self.session = payload.session
        self.rawSamples = payload.rawSamples
        self.activeDiveAcceptedSamples = payload.acceptedSamples
        self.activeDiveEvents = payload.activeEvents
        self.activeDiveStartedAtMonotonic = payload.currentDive?.startedAtMonotonicSeconds
        self.currentRecoveryInterval = payload.recoveryInterval
        self.lastDiveDurationSeconds = payload.currentDive?.durationSeconds ?? payload.session.dives.last?.durationSeconds ?? 0
        self.manualFallbackActive = payload.lifecyclePhase == .sensorDegraded
        self.sensorAvailable = payload.lifecyclePhase != .sensorDegraded
        self.sessionArmed = payload.lifecyclePhase != .idle
        self.pendingManualDescent = false
        self.pendingManualSurface = false
        self.endSessionRequested = payload.lifecyclePhase == .ended
        self.snapshot = ApneaSessionEngineSnapshot(
            phase: payload.lifecyclePhase,
            session: payload.session,
            currentDepthMeters: payload.feedState.lastAccepted?.depthMeters,
            verticalSpeedMetersPerSecond: payload.feedState.lastAccepted?.verticalSpeedMetersPerSecond ?? 0,
            diveElapsedSeconds: 0,
            surfaceElapsedSeconds: 0,
            sessionElapsedSeconds: 0,
            totalUnderwaterSeconds: payload.session.statistics.totalUnderwaterSeconds,
            requiredRecoverySeconds: payload.recoveryInterval?.plannedSeconds ?? 0,
            recoveryElapsedSeconds: payload.recoveryInterval?.completedSeconds ?? 0,
            recoveryRemainingSeconds: payload.recoveryInterval.map { max(0, $0.plannedSeconds - ($0.completedSeconds ?? 0)) },
            isRecoveryComplete: (payload.recoveryInterval?.plannedSeconds ?? 0) <= (payload.recoveryInterval?.completedSeconds ?? 0),
            sensorHealth: payload.lifecyclePhase == .sensorDegraded ? .degraded : .available,
            rawSampleCount: payload.rawSamples.count,
            acceptedSampleCount: payload.session.dives.reduce(0) { $0 + $1.samples.count } + payload.acceptedSamples.count,
            activeDiveSampleCount: payload.acceptedSamples.count
        )
    }

    mutating func armSession(at wallClock: Date = Date()) {
        sessionArmed = true
        runMachine(feedAccepted: false, acceptedDepth: nil, verticalSpeed: 0, wallClock: wallClock, tickOnly: true)
        refreshSnapshot(wallClock: wallClock)
    }

    mutating func endSession(at wallClock: Date = Date()) {
        endSessionRequested = true
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: wallClock, tickOnly: true)
        session.state = .completed
        session.endedAtMonotonicSeconds = sessionMonotonicElapsed(wallClock: wallClock)
        refreshSnapshot(wallClock: wallClock)
    }

    mutating func enableManualFallback() {
        manualFallbackActive = true
        sensorAvailable = false
        refreshSnapshot(wallClock: Date())
    }

    mutating func disableManualFallback() {
        manualFallbackActive = false
        refreshSnapshot(wallClock: Date())
    }

    mutating func triggerManualDescent(at wallClock: Date = Date()) {
        guard manualFallbackActive else { return }
        if let interval = currentRecoveryInterval,
           (interval.completedSeconds ?? 0) < interval.plannedSeconds,
           !session.warnings.contains(.incompleteRecovery) {
            session.warnings.append(.incompleteRecovery)
        }
        pendingManualDescent = true
        ingest(raw: DepthMeasurementRaw(depthMeters: configuration.immersionStartDepthMeters + 0.5, sensorTimestamp: wallClock, receivedAt: wallClock), wallClock: wallClock)
        pendingManualDescent = false
    }

    mutating func triggerManualSurface(at wallClock: Date = Date()) {
        guard manualFallbackActive else { return }
        pendingManualSurface = true
        ingest(raw: DepthMeasurementRaw(depthMeters: 0, sensorTimestamp: wallClock, receivedAt: wallClock), wallClock: wallClock)
        pendingManualSurface = false
    }

    mutating func exportCheckpoint(now wallClock: Date = Date()) throws -> ApneaSessionCheckpointEnvelope {
        let payload = ApneaSessionCheckpointPayload(
            sessionID: session.id,
            sessionState: session.state,
            lifecyclePhase: tracker.phase,
            session: session,
            currentDive: activeDiveStartedAtMonotonic.map { start in
                ApneaDive(
                    startedAtMonotonicSeconds: start,
                    durationSeconds: diveClock.elapsed(now: wallClock),
                    samples: activeDiveAcceptedSamples,
                    events: activeDiveEvents,
                    recoveryBefore: currentRecoveryInterval
                )
            },
            rawSamples: rawSamples,
            acceptedSamples: activeDiveAcceptedSamples,
            activeEvents: activeDiveEvents,
            recoveryInterval: currentRecoveryInterval,
            profileID: session.profile?.id,
            alarmState: .empty,
            sessionClock: sessionClock.exportSnapshot(),
            diveClock: diveClock.exportSnapshot(),
            tracker: tracker,
            feedState: feedState,
            savedAtWallClock: wallClock,
            savedAtMonotonicSeconds: sessionMonotonicElapsed(wallClock: wallClock)
        )
        return try ApneaSessionCheckpointIntegrity.makeEnvelope(payload: payload)
    }

    @discardableResult
    mutating func ingest(
        raw: DepthMeasurementRaw,
        wallClock: Date = Date(),
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> DepthFeedIngestResult {
        let result = DepthMeasurementFeed.ingest(raw: raw, state: &feedState, configuration: feedConfiguration)
        appendRawSample(from: result, wallClock: wallClock)

        if let accepted = result.accepted {
            sensorAvailable = true
            runMachine(
                feedAccepted: true,
                acceptedDepth: accepted.depthMeters,
                verticalSpeed: accepted.verticalSpeedMetersPerSecond,
                wallClock: wallClock,
                uptime: uptime
            )
            appendAcceptedSample(from: accepted, wallClock: wallClock)
        } else {
            runMachine(feedAccepted: false, acceptedDepth: nil, verticalSpeed: 0, wallClock: wallClock, uptime: uptime)
        }

        refreshSnapshot(wallClock: wallClock, uptime: uptime)
        return result
    }

    mutating func tick(now: Date = Date(), uptime: TimeInterval = ProcessInfo.processInfo.systemUptime) {
        runMachine(feedAccepted: false, acceptedDepth: snapshot.currentDepthMeters, verticalSpeed: 0, wallClock: now, uptime: uptime, tickOnly: true)
        refreshSnapshot(wallClock: now, uptime: uptime)
    }

    mutating func replayProfile(
        depths: [Double],
        intervalSeconds: TimeInterval,
        startDate: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) {
        var timestamp = startDate
        for depth in depths {
            ingest(raw: DepthMeasurementRaw(depthMeters: depth, sensorTimestamp: timestamp, receivedAt: timestamp), wallClock: timestamp)
            timestamp = timestamp.addingTimeInterval(intervalSeconds)
        }
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
        let input = ApneaLifecycleMachineInput(
            configuration: configuration,
            monotonicNow: monotonicNow,
            wallClockNow: wallClock,
            acceptedDepthMeters: acceptedDepth,
            verticalSpeedMetersPerSecond: verticalSpeed,
            feedAccepted: feedAccepted,
            sensorAvailable: sensorAvailable,
            manualFallbackActive: manualFallbackActive,
            manualDescentTriggered: pendingManualDescent,
            manualSurfaceTriggered: pendingManualSurface,
            sessionArmed: sessionArmed,
            endSessionRequested: endSessionRequested,
            tickOnly: tickOnly
        )
        let output = ApneaLifecycleStateMachine.evaluate(input: input, tracker: tracker)
        tracker = output.tracker
        applyTransitionEvents(output.events, wallClock: wallClock)
    }

    private mutating func applyTransitionEvents(_ events: [ApneaLifecycleTransitionEvent], wallClock: Date) {
        for event in events {
            switch event {
            case .phaseChanged:
                break
            case .diveStarted(let atMonotonic):
                if let interval = currentRecoveryInterval,
                   (interval.completedSeconds ?? 0) < interval.plannedSeconds {
                    session.warnings.append(.incompleteRecovery)
                }
                activeDiveStartedAtMonotonic = atMonotonic
                diveClock.reset(anchorDate: wallClock)
                activeDiveAcceptedSamples = []
                activeDiveEvents = [ApneaEvent(kind: .descentStart, monotonicRelativeTimestampSeconds: atMonotonic, wallClockTimestamp: wallClock)]
                if session.state == .planned {
                    session.state = .active
                    session.startedAtMonotonicSeconds = session.startedAtMonotonicSeconds ?? atMonotonic
                }
            case .diveEnded(let atMonotonic, let startedAtMonotonic, let maxDepth):
                activeDiveEvents.append(ApneaEvent(kind: .diveEnd, monotonicRelativeTimestampSeconds: atMonotonic, wallClockTimestamp: wallClock, depthMeters: maxDepth))
                commitActiveDive(endMonotonic: atMonotonic, startedAtMonotonic: startedAtMonotonic, endWallClock: wallClock, maxDepthMeters: maxDepth)
            case .recoveryStarted(let atMonotonic):
                activeDiveEvents.append(ApneaEvent(kind: .recoveryStart, monotonicRelativeTimestampSeconds: atMonotonic, wallClockTimestamp: wallClock))
                currentRecoveryInterval?.startedAtMonotonicSeconds = atMonotonic
            case .recoveryCompleted(let atMonotonic):
                activeDiveEvents.append(ApneaEvent(kind: .recoveryComplete, monotonicRelativeTimestampSeconds: atMonotonic, wallClockTimestamp: wallClock))
                if var interval = currentRecoveryInterval {
                    interval.endedAtMonotonicSeconds = atMonotonic
                    interval.completedSeconds = interval.plannedSeconds
                    currentRecoveryInterval = interval
                }
            case .sensorDegraded:
                sensorAvailable = false
            case .sensorRecovered:
                sensorAvailable = true
            }
        }
    }

    private mutating func commitActiveDive(
        endMonotonic: TimeInterval,
        startedAtMonotonic: TimeInterval,
        endWallClock: Date,
        maxDepthMeters: Double
    ) {
        let duration = max(0, endMonotonic - startedAtMonotonic)
        lastDiveDurationSeconds = duration
        let metrics = ApneaDomainSupport.depthMetrics(from: activeDiveAcceptedSamples)
        let planned = ApneaRecoveryComputation.requiredRecoverySeconds(policy: recoveryPolicy, lastDiveDurationSeconds: duration)
        let recovery = ApneaRecoveryInterval(startedAtMonotonicSeconds: endMonotonic, plannedSeconds: planned)
        currentRecoveryInterval = recovery
        var dive = ApneaDive(
            id: UUID(),
            startedAtMonotonicSeconds: startedAtMonotonic,
            endedAtMonotonicSeconds: endMonotonic,
            startedAtWallClock: endWallClock.addingTimeInterval(-duration),
            endedAtWallClock: endWallClock,
            durationSeconds: duration,
            maxDepthMeters: max(maxDepthMeters, metrics.maxDepthMeters),
            averageDepthMeters: metrics.averageDepthMeters,
            samples: activeDiveAcceptedSamples,
            events: activeDiveEvents,
            recoveryAfter: recovery
        )
        dive.samples = dive.normalizedSamples()
        session.dives.append(dive)
        session.statistics = session.refreshedStatistics()
        activeDiveStartedAtMonotonic = nil
        activeDiveAcceptedSamples = []
        activeDiveEvents = []
        diveClock.clear()
    }

    private mutating func appendRawSample(from result: DepthFeedIngestResult, wallClock: Date) {
        let depth = result.raw.depthMeters ?? result.accepted?.depthMeters ?? 0
        let monotonic = activeDiveStartedAtMonotonic.map { sessionMonotonicElapsed(wallClock: wallClock) - $0 } ?? sessionMonotonicElapsed(wallClock: wallClock)
        rawSamples.append(
            ApneaSample(
                monotonicRelativeTimestampSeconds: max(0, monotonic),
                wallClockTimestamp: result.raw.sensorTimestamp,
                depthMeters: depth.isFinite ? depth : 0,
                temperatureCelsius: result.raw.temperatureCelsius,
                verticalSpeedMetersPerSecond: result.accepted?.verticalSpeedMetersPerSecond ?? 0,
                quality: result.quality.apneaDataQuality
            )
        )
    }

    private mutating func appendAcceptedSample(from accepted: DepthMeasurementAccepted, wallClock: Date) {
        guard activeDiveStartedAtMonotonic != nil else { return }
        let diveElapsed = diveClock.elapsed(now: wallClock)
        activeDiveAcceptedSamples.append(
            ApneaSample(
                monotonicRelativeTimestampSeconds: diveElapsed,
                wallClockTimestamp: accepted.sensorTimestamp,
                depthMeters: accepted.depthMeters,
                temperatureCelsius: accepted.temperatureCelsius,
                verticalSpeedMetersPerSecond: accepted.verticalSpeedMetersPerSecond,
                quality: .measured
            )
        )
    }

    private mutating func sessionMonotonicElapsed(
        wallClock: Date,
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> TimeInterval {
        sessionClock.elapsed(now: wallClock, uptime: uptime)
    }

    private mutating func refreshSnapshot(
        wallClock: Date,
        uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) {
        let sessionElapsed = sessionMonotonicElapsed(wallClock: wallClock, uptime: uptime)
        let diveElapsed = activeDiveStartedAtMonotonic == nil ? 0 : diveClock.elapsed(now: wallClock, uptime: uptime)
        let surfaceElapsed: TimeInterval
        if let started = tracker.recoveryStartedAt {
            surfaceElapsed = max(0, sessionElapsed - started)
        } else {
            surfaceElapsed = 0
        }
        let requiredRecovery = currentRecoveryInterval?.plannedSeconds ?? ApneaRecoveryComputation.requiredRecoverySeconds(policy: recoveryPolicy, lastDiveDurationSeconds: lastDiveDurationSeconds)
        let recoveryElapsed = min(requiredRecovery, surfaceElapsed)
        let recoveryRemaining = max(0, requiredRecovery - recoveryElapsed)

        if tracker.phase == .recovery, var interval = currentRecoveryInterval {
            interval.completedSeconds = recoveryElapsed
            if recoveryRemaining == 0 {
                interval.endedAtMonotonicSeconds = sessionElapsed
            }
            currentRecoveryInterval = interval
        }

        let health: ApneaSensorHealth
        if manualFallbackActive {
            health = .manualFallback
        } else if tracker.phase == .sensorDegraded {
            health = .degraded
        } else {
            health = .available
        }

        snapshot = ApneaSessionEngineSnapshot(
            phase: tracker.phase,
            session: session,
            currentDepthMeters: feedState.lastAccepted?.depthMeters,
            verticalSpeedMetersPerSecond: feedState.lastAccepted?.verticalSpeedMetersPerSecond ?? 0,
            diveElapsedSeconds: diveElapsed,
            surfaceElapsedSeconds: surfaceElapsed,
            sessionElapsedSeconds: sessionElapsed,
            totalUnderwaterSeconds: session.statistics.totalUnderwaterSeconds,
            requiredRecoverySeconds: requiredRecovery,
            recoveryElapsedSeconds: recoveryElapsed,
            recoveryRemainingSeconds: tracker.phase == .recovery ? recoveryRemaining : nil,
            isRecoveryComplete: recoveryRemaining == 0,
            sensorHealth: health,
            rawSampleCount: rawSamples.count,
            acceptedSampleCount: session.dives.reduce(0) { $0 + $1.samples.count } + activeDiveAcceptedSamples.count,
            activeDiveSampleCount: activeDiveAcceptedSamples.count
        )
    }
}
