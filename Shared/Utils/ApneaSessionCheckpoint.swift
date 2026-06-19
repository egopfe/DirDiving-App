import Foundation

struct ApneaAlarmCheckpointState: Codable, Hashable, Sendable {
    var activeAlarmIDs: [UUID]
    var snoozedAlarmIDs: [UUID]

    static let empty = ApneaAlarmCheckpointState(activeAlarmIDs: [], snoozedAlarmIDs: [])
}

struct ApneaSessionCheckpointPayload: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var sessionID: UUID
    var sessionState: ApneaSessionState
    var lifecyclePhase: ApneaLifecyclePhase
    var session: ApneaSession
    var currentDive: ApneaDive?
    var rawSamples: [ApneaSample]
    var acceptedSamples: [ApneaSample]
    var activeEvents: [ApneaEvent]
    var recoveryInterval: ApneaRecoveryInterval?
    var profileID: UUID?
    var alarmState: ApneaAlarmCheckpointState
    var sessionClock: MonotonicElapsedClock.Snapshot
    var diveClock: MonotonicElapsedClock.Snapshot
    var tracker: ApneaLifecycleTracker
    var feedState: DepthMeasurementFeedState
    var savedAtWallClock: Date
    var savedAtMonotonicSeconds: TimeInterval
    var lifecycleConfiguration: ApneaLifecycleConfiguration
    var recoveryPolicy: ApneaRecoveryPolicy

    init(
        sessionID: UUID,
        sessionState: ApneaSessionState,
        lifecyclePhase: ApneaLifecyclePhase,
        session: ApneaSession,
        currentDive: ApneaDive?,
        rawSamples: [ApneaSample],
        acceptedSamples: [ApneaSample],
        activeEvents: [ApneaEvent],
        recoveryInterval: ApneaRecoveryInterval?,
        profileID: UUID?,
        alarmState: ApneaAlarmCheckpointState,
        sessionClock: MonotonicElapsedClock.Snapshot,
        diveClock: MonotonicElapsedClock.Snapshot,
        tracker: ApneaLifecycleTracker,
        feedState: DepthMeasurementFeedState,
        savedAtWallClock: Date,
        savedAtMonotonicSeconds: TimeInterval,
        lifecycleConfiguration: ApneaLifecycleConfiguration = .default,
        recoveryPolicy: ApneaRecoveryPolicy = .default
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.sessionID = sessionID
        self.sessionState = sessionState
        self.lifecyclePhase = lifecyclePhase
        self.session = session
        self.currentDive = currentDive
        self.rawSamples = rawSamples
        self.acceptedSamples = acceptedSamples
        self.activeEvents = activeEvents
        self.recoveryInterval = recoveryInterval
        self.profileID = profileID
        self.alarmState = alarmState
        self.sessionClock = sessionClock
        self.diveClock = diveClock
        self.tracker = tracker
        self.feedState = feedState
        self.savedAtWallClock = savedAtWallClock
        self.savedAtMonotonicSeconds = savedAtMonotonicSeconds
        self.lifecycleConfiguration = lifecycleConfiguration
        self.recoveryPolicy = recoveryPolicy
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, sessionID, sessionState, lifecyclePhase, session, currentDive
        case rawSamples, acceptedSamples, activeEvents, recoveryInterval, profileID, alarmState
        case sessionClock, diveClock, tracker, feedState, savedAtWallClock, savedAtMonotonicSeconds
        case lifecycleConfiguration, recoveryPolicy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        sessionID = try container.decode(UUID.self, forKey: .sessionID)
        sessionState = try container.decode(ApneaSessionState.self, forKey: .sessionState)
        lifecyclePhase = try container.decode(ApneaLifecyclePhase.self, forKey: .lifecyclePhase)
        session = try container.decode(ApneaSession.self, forKey: .session)
        currentDive = try container.decodeIfPresent(ApneaDive.self, forKey: .currentDive)
        rawSamples = try container.decode([ApneaSample].self, forKey: .rawSamples)
        acceptedSamples = try container.decode([ApneaSample].self, forKey: .acceptedSamples)
        activeEvents = try container.decode([ApneaEvent].self, forKey: .activeEvents)
        recoveryInterval = try container.decodeIfPresent(ApneaRecoveryInterval.self, forKey: .recoveryInterval)
        profileID = try container.decodeIfPresent(UUID.self, forKey: .profileID)
        alarmState = try container.decode(ApneaAlarmCheckpointState.self, forKey: .alarmState)
        sessionClock = try container.decode(MonotonicElapsedClock.Snapshot.self, forKey: .sessionClock)
        diveClock = try container.decode(MonotonicElapsedClock.Snapshot.self, forKey: .diveClock)
        tracker = try container.decode(ApneaLifecycleTracker.self, forKey: .tracker)
        feedState = try container.decode(DepthMeasurementFeedState.self, forKey: .feedState)
        savedAtWallClock = try container.decode(Date.self, forKey: .savedAtWallClock)
        savedAtMonotonicSeconds = try container.decode(TimeInterval.self, forKey: .savedAtMonotonicSeconds)
        lifecycleConfiguration = try container.decodeIfPresent(ApneaLifecycleConfiguration.self, forKey: .lifecycleConfiguration) ?? .default
        recoveryPolicy = try container.decodeIfPresent(ApneaRecoveryPolicy.self, forKey: .recoveryPolicy) ?? .default
    }
}

struct ApneaSessionCheckpointEnvelope: Codable, Hashable, Sendable {
    var payloadData: Data
    var checksum: String
}

enum ApneaSessionCheckpointIntegrity {
    private static func encodePayload(_ payload: ApneaSessionCheckpointPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(payload)
    }

    private static func decodePayload(_ data: Data) throws -> ApneaSessionCheckpointPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode(ApneaSessionCheckpointPayload.self, from: data)
    }

    static func checksum(for data: Data) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for b in data {
            hash ^= UInt64(b)
            hash = hash &* 0x100000001b3
        }
        return String(hash, radix: 16)
    }

    static func makeEnvelope(payload: ApneaSessionCheckpointPayload) throws -> ApneaSessionCheckpointEnvelope {
        let data = try encodePayload(payload)
        return ApneaSessionCheckpointEnvelope(payloadData: data, checksum: checksum(for: data))
    }

    static func payload(from envelope: ApneaSessionCheckpointEnvelope) throws -> ApneaSessionCheckpointPayload {
        guard checksum(for: envelope.payloadData) == envelope.checksum else {
            throw NSError(domain: "ApneaSessionCheckpoint", code: 2, userInfo: [NSLocalizedDescriptionKey: "Checkpoint checksum mismatch"])
        }
        return try decodePayload(envelope.payloadData)
    }
}

enum ApneaSessionCheckpointStore {
    static func write(_ envelope: ApneaSessionCheckpointEnvelope, to fileURL: URL) throws {
        let data = try JSONEncoder().encode(envelope)
        let tempURL = fileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)
        _ = try? FileManager.default.removeItem(at: fileURL)
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
    }

    static func read(from fileURL: URL) throws -> ApneaSessionCheckpointEnvelope {
        let data = try Data(contentsOf: fileURL)
        let envelope = try JSONDecoder().decode(ApneaSessionCheckpointEnvelope.self, from: data)
        _ = try ApneaSessionCheckpointIntegrity.payload(from: envelope)
        return envelope
    }
}
