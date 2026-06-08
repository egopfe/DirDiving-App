import Foundation

enum ManualDiveEditorSaveError: LocalizedError, Equatable {
    case validation(String)

    var errorDescription: String? {
        switch self {
        case .validation(let message):
            return message
        }
    }
}

enum ManualDiveEditorValidation {
    static func depthOrderError(maxMeters: Double, avgMeters: Double) -> String? {
        guard maxMeters.isFinite, avgMeters.isFinite, maxMeters > 0, avgMeters > 0 else {
            return String(localized: "manual_dive.validation.invalid_depth")
        }
        guard maxMeters >= avgMeters else {
            return String(localized: "manual_dive.validation.depth_order")
        }
        return nil
    }

    static func clampedDurationMinutes(_ value: Double) -> Double {
        min(300, max(5, value))
    }

    static func makeSyntheticSession(
        existing: DiveSession?,
        startDate: Date,
        durationMinutes: Double,
        maxMeters: Double,
        avgMeters: Double,
        siteName: String,
        entryLatitude: String,
        entryLongitude: String,
        exitLatitude: String,
        exitLongitude: String,
        equipmentUsed: String,
        entryPressureText: String,
        exitPressureText: String,
        decompressionNotes: String,
        notes: String,
        gasLabel: DiveGasLabel,
        ccrLogbookMetadata: CCRLogbookMetadata? = nil,
        unitPreference: IOSUnitPreference
    ) -> Result<DiveSession, ManualDiveEditorSaveError> {
        if let error = depthOrderError(maxMeters: maxMeters, avgMeters: avgMeters) {
            return .failure(.validation(error))
        }
        let duration = clampedDurationMinutes(durationMinutes) * 60
        let endDate = startDate.addingTimeInterval(duration)
        let entryGPS = makeGPS(lat: entryLatitude, lon: entryLongitude, timestamp: startDate)
        let exitGPS = makeGPS(lat: exitLatitude, lon: exitLongitude, timestamp: endDate)
        let samples = ManualDiveSampleBuilder.makeSamples(
            startDate: startDate,
            endDate: endDate,
            maxDepthMeters: maxMeters,
            avgDepthMeters: avgMeters
        )
        let summary = DiveProfileMath.summary(samples: samples, startDate: startDate, endDate: endDate)
        let ttv = DiveProfileMath.ttvIndex(averageDepthMeters: summary.averageDepthMeters, durationSeconds: duration)
        let pressures = parsedManualPressures(
            entryPressureText: entryPressureText,
            exitPressureText: exitPressureText,
            unitPreference: unitPreference
        )
        let session = DiveSession(
            id: existing?.id ?? UUID(),
            startDate: startDate,
            endDate: endDate,
            durationSeconds: duration,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: existing?.avgWaterTemperatureCelsius,
            ttv: ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            samples: samples,
            siteName: siteName.isEmpty ? String(localized: "manual_dive.default_site") : siteName,
            buddy: existing?.buddy,
            notes: notes.isEmpty ? nil : notes,
            gasLabel: gasLabel,
            isManual: true,
            equipmentUsed: equipmentUsed.isEmpty ? nil : equipmentUsed,
            entryPressureText: pressures.entryText,
            exitPressureText: pressures.exitText,
            entryPressureBar: pressures.entryBar,
            exitPressureBar: pressures.exitBar,
            decompressionNotes: decompressionNotes.isEmpty ? nil : decompressionNotes,
            ccrLogbookMetadata: gasLabel == .ccr ? ccrLogbookMetadata : nil
        )
        return .success(session)
    }

    private static func makeGPS(lat: String, lon: String, timestamp: Date) -> GPSPoint? {
        makeGPSPoint(lat: lat, lon: lon, timestamp: timestamp)
    }

    static func makeGPSPoint(lat: String, lon: String, timestamp: Date) -> GPSPoint? {
        guard let latitude = Double(lat.replacingOccurrences(of: ",", with: ".")),
              let longitude = Double(lon.replacingOccurrences(of: ",", with: ".")) else { return nil }
        let point = GPSPoint(latitude: latitude, longitude: longitude, horizontalAccuracy: 10, timestamp: timestamp)
        return DiveProfileMath.isValidGPS(point) ? point : nil
    }

    static func parsedManualPressures(
        entryPressureText: String,
        exitPressureText: String,
        unitPreference: IOSUnitPreference
    ) -> (entryText: String?, exitText: String?, entryBar: Double?, exitBar: Double?) {
        let unit = PressureDisplayMath.pressureUnit(for: unitPreference)
        let entryBar = PressureDisplayMath.parsePressureBar(from: entryPressureText, inputUnit: unit)
        let exitBar = PressureDisplayMath.parsePressureBar(from: exitPressureText, inputUnit: unit)
        let entryText = entryPressureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : entryPressureText
        let exitText = exitPressureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : exitPressureText
        return (entryText, exitText, entryBar, exitBar)
    }
}

enum ManualDiveSampleBuilder {
    static func makeSamples(startDate: Date, endDate: Date, maxDepthMeters: Double, avgDepthMeters: Double) -> [DiveSample] {
        let duration = max(1, endDate.timeIntervalSince(startDate))
        let ratio = maxDepthMeters > 0 ? min(1, max(0, avgDepthMeters / maxDepthMeters)) : 0
        let descentEnd = startDate.addingTimeInterval(min(1, duration * 0.05))
        let holdEnd = startDate.addingTimeInterval(max(1, duration * ratio))
        return [
            DiveSample(timestamp: startDate, depthMeters: 0, temperatureCelsius: nil),
            DiveSample(timestamp: descentEnd, depthMeters: maxDepthMeters, temperatureCelsius: nil),
            DiveSample(timestamp: holdEnd, depthMeters: maxDepthMeters, temperatureCelsius: nil),
            DiveSample(timestamp: endDate, depthMeters: 0, temperatureCelsius: nil)
        ]
    }
}
