import Foundation

enum DivingExportCoordinator {
    static func buildCandidates(
        from sessions: [DiveSession],
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> [DivingExportCandidate] {
        sessions.map { session in
            buildCandidate(for: session, privacyOptions: privacyOptions)
        }
    }

    static func buildCandidate(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> DivingExportCandidate {
        var warnings: [DivingExportWarning] = []
        if session.isDemoDive {
            warnings.append(.demoDive)
        }
        if session.samples.isEmpty || !session.hasDepthProfile {
            warnings.append(.missingSamples)
        }
        if session.avgWaterTemperatureCelsius == nil {
            warnings.append(.missingTemperature)
        }
        if session.entryGPS == nil && session.exitGPS == nil {
            warnings.append(.missingGPS)
        }
        if DivingExportPrivacyPolicy.requiresLocationConfirmation(entry: session.entryGPS, exit: session.exitGPS),
           privacyOptions.locationPrecision == .omitted {
            warnings.append(.privacyCoordinatesReduced)
        }
        let exportable = !session.isDemoDive && session.hasDepthProfile && !session.samples.isEmpty
        return DivingExportCandidate(
            id: session.id,
            session: session,
            isSelected: false,
            isExportable: exportable,
            warnings: warnings
        )
    }

    static func export(
        sessions: [DiveSession],
        format: DivingExportFormat,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> Result<DivingExportReport, DivingExportError> {
        guard !sessions.isEmpty else { return .failure(.emptySelection) }

        let exportable = sessions.filter { !$0.isDemoDive && $0.hasDepthProfile && !$0.samples.isEmpty }
        let skipped = sessions.count - exportable.count
        guard !exportable.isEmpty else { return .failure(.emptySamples) }

        var warningsCount = 0
        for session in exportable {
            let candidate = buildCandidate(for: session, privacyOptions: privacyOptions)
            warningsCount += candidate.warnings.count
        }

        switch format {
        case .csv:
            guard exportable.count == 1, let session = exportable.first else {
                return .failure(.unsupportedMultiCSV)
            }
            switch SubsurfaceExportService.writeCSV(for: session, privacyOptions: privacyOptions) {
            case .success(let url):
                return .success(
                    DivingExportReport(
                        format: .csv,
                        exportedCount: 1,
                        skippedCount: skipped,
                        warningsCount: warningsCount,
                        url: url,
                        message: nil
                    )
                )
            case .failure(let error):
                return .failure(.writeFailed(error.localizedDescription))
            }
        case .subsurfaceXML:
            switch DivingSubsurfaceXMLExportService.writeXML(for: exportable, privacyOptions: privacyOptions) {
            case .success(let url):
                return .success(
                    DivingExportReport(
                        format: .subsurfaceXML,
                        exportedCount: exportable.count,
                        skippedCount: skipped,
                        warningsCount: warningsCount,
                        url: url,
                        message: nil
                    )
                )
            case .failure(let error):
                return .failure(.writeFailed(error.localizedDescription))
            }
        case .uddf:
            switch DivingUDDFExportService.writeUDDF(for: exportable, privacyOptions: privacyOptions) {
            case .success(let url):
                return .success(
                    DivingExportReport(
                        format: .uddf,
                        exportedCount: exportable.count,
                        skippedCount: skipped,
                        warningsCount: warningsCount,
                        url: url,
                        message: nil
                    )
                )
            case .failure(let error):
                return .failure(.writeFailed(error.localizedDescription))
            }
        }
    }
}
