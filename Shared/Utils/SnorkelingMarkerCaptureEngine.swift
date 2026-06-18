import Foundation

enum SnorkelingMarkerCaptureEngine {
    static func capture(
        request: SnorkelingMarkerCaptureRequest,
        monotonicNow: TimeInterval,
        wallClockNow: Date,
        sessionID: UUID,
        depthMeters: Double?,
        temperatureCelsius: Double?,
        headingDegrees: Double?,
        isUnderwater: Bool,
        gpsAcceptedFix: SnorkelingGPSAcceptedFix?,
        gpsPresentationState: SnorkelingGPSPresentationState,
        entryPoint: SnorkelingEntryPoint?,
        hapticsEnabled: Bool,
        missionModeEnabled: Bool
    ) -> SnorkelingMarkerCaptureResult {
        if request.category == .custom {
            let label = request.customCategoryLabel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if label.isEmpty {
                return SnorkelingMarkerCaptureResult(rejection: .invalidCustomCategory)
            }
        }
        if let note = request.note, note.count > SnorkelingMarker.maximumNoteLength {
            return SnorkelingMarkerCaptureResult(rejection: .noteTooLong)
        }

        let position = resolvePosition(
            request: request,
            isUnderwater: isUnderwater,
            gpsAcceptedFix: gpsAcceptedFix,
            gpsPresentationState: gpsPresentationState
        )
        guard let position else {
            return SnorkelingMarkerCaptureResult(rejection: .coordinateRequired)
        }

        var distanceFromEntry: Double?
        var bearingFromEntry: Double?
        if let entry = entryPoint,
           let latitude = position.latitude,
           let longitude = position.longitude {
            let current = (latitude: latitude, longitude: longitude)
            let entryCoordinate = (latitude: entry.latitude, longitude: entry.longitude)
            distanceFromEntry = SnorkelingDomainSupport.distanceMeters(from: entryCoordinate, to: current)
            bearingFromEntry = SnorkelingDomainSupport.bearingDegrees(from: entryCoordinate, to: current)
        }

        let marker = SnorkelingMarker(
            category: request.category,
            customCategoryLabel: request.customCategoryLabel,
            monotonicRelativeTimestampSeconds: monotonicNow,
            wallClockTimestamp: wallClockNow,
            positionQuality: position.quality,
            latitude: position.latitude,
            longitude: position.longitude,
            horizontalAccuracyMeters: position.horizontalAccuracyMeters,
            depthMeters: depthMeters,
            temperatureCelsius: temperatureCelsius,
            headingDegrees: headingDegrees,
            distanceFromEntryMeters: distanceFromEntry,
            bearingFromEntryDegrees: bearingFromEntry,
            sessionID: sessionID,
            photoReferenceID: request.photoReferenceID,
            note: request.note
        )

        let validationIssues = SnorkelingDomainValidator.validate(marker: marker)
        if !validationIssues.isEmpty {
            if validationIssues.contains(where: { if case .invalidCoordinate = $0 { return true } else { return false } }) {
                return SnorkelingMarkerCaptureResult(rejection: .underwaterMeasuredGPSRejected)
            }
            return SnorkelingMarkerCaptureResult(rejection: .coordinateRequired)
        }

        let event = SnorkelingEvent(
            kind: .markerPlaced,
            monotonicRelativeTimestampSeconds: monotonicNow,
            wallClockTimestamp: wallClockNow,
            latitude: marker.latitude,
            longitude: marker.longitude,
            depthMeters: depthMeters,
            note: request.note,
            relatedMarkerID: marker.id
        )
        let overlay = SnorkelingOperationalOverlay(
            kind: .markerSaved,
            titleKey: "snorkeling.marker.saved",
            subtitle: marker.category.rawValue,
            severity: .info,
            eventID: event.id
        )
        let hapticCue = hapticsEnabled
            ? SnorkelingHapticCue(pattern: .markerSaved, atMonotonicSeconds: monotonicNow, sourceID: marker.id)
            : nil
        _ = missionModeEnabled

        return SnorkelingMarkerCaptureResult(
            marker: marker,
            event: event,
            overlay: overlay,
            hapticCue: hapticCue
        )
    }

    // MARK: - Private

    private struct ResolvedPosition {
        var quality: SnorkelingMarkerPositionQuality
        var latitude: Double?
        var longitude: Double?
        var horizontalAccuracyMeters: Double?
    }

    private static func resolvePosition(
        request: SnorkelingMarkerCaptureRequest,
        isUnderwater: Bool,
        gpsAcceptedFix: SnorkelingGPSAcceptedFix?,
        gpsPresentationState: SnorkelingGPSPresentationState
    ) -> ResolvedPosition? {
        if isUnderwater || gpsPresentationState == .underwaterUnavailable {
            return request.allowSaveWithoutCoordinates
                ? ResolvedPosition(quality: .noFix, latitude: nil, longitude: nil, horizontalAccuracyMeters: nil)
                : nil
        }

        guard let fix = gpsAcceptedFix else {
            return request.allowSaveWithoutCoordinates
                ? ResolvedPosition(quality: .noFix, latitude: nil, longitude: nil, horizontalAccuracyMeters: nil)
                : nil
        }

        let quality: SnorkelingMarkerPositionQuality
        switch fix.gpsQuality {
        case .measured where gpsPresentationState == .tracking:
            quality = .measured
        case .stale, .measured:
            quality = .degraded
        default:
            return request.allowSaveWithoutCoordinates
                ? ResolvedPosition(quality: .unavailable, latitude: nil, longitude: nil, horizontalAccuracyMeters: nil)
                : nil
        }

        guard SnorkelingDomainSupport.isValidCoordinate(latitude: fix.latitude, longitude: fix.longitude) else {
            return nil
        }

        return ResolvedPosition(
            quality: quality,
            latitude: fix.latitude,
            longitude: fix.longitude,
            horizontalAccuracyMeters: fix.horizontalAccuracyMeters
        )
    }
}
