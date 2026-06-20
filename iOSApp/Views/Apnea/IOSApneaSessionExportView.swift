import SwiftUI

struct IOSApneaSessionExportView: View {
    let session: ApneaSession
    private let cloudCapability = ApneaCloudCapability.current
    @State private var includeGPS = false
    @State private var includeBuddyContact = false
    @State private var includeEmergencyContact = false
    @State private var locationAcknowledged = false
    @State private var sensitiveAcknowledged = false
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var errorMessage: String?

    private var privacyOptions: ApneaExportPrivacyOptions {
        ApneaExportPrivacyOptions(
            includeSurfaceGPS: includeGPS,
            includeBuddyContactDetails: includeBuddyContact,
            includeEmergencyContact: includeEmergencyContact,
            locationSharingAcknowledged: locationAcknowledged
        )
    }

    private var needsLocationConfirmation: Bool {
        ApneaExportPrivacyPolicy.requiresLocationConfirmation(for: session)
    }

    private var needsSensitiveConfirmation: Bool {
        ApneaExportPrivacyPolicy.requiresSensitiveDataConfirmation(for: session)
            || session.buddy != nil
    }

    var body: some View {
        DIRScreenContainer {
            List {
                if needsLocationConfirmation {
                    Section(DIRIOSLocalizer.string("apnea.ios.export.privacy")) {
                        Toggle(DIRIOSLocalizer.string("apnea.ios.export.include_gps"), isOn: $includeGPS)
                        if includeGPS {
                            Toggle(DIRIOSLocalizer.string("apnea.ios.export.location_ack"), isOn: $locationAcknowledged)
                                .tint(DIRTheme.cyan)
                        }
                        Text(DIRIOSLocalizer.string("apnea.ios.export.privacy_note"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
                if needsSensitiveConfirmation {
                    Section(DIRIOSLocalizer.string("apnea.ios.export.sensitive")) {
                        Toggle(DIRIOSLocalizer.string("apnea.ios.export.include_buddy"), isOn: $includeBuddyContact)
                        Toggle(DIRIOSLocalizer.string("apnea.ios.export.include_emergency"), isOn: $includeEmergencyContact)
                        Toggle(DIRIOSLocalizer.string("apnea.ios.export.sensitive_ack"), isOn: $sensitiveAcknowledged)
                            .tint(DIRTheme.cyan)
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.export.formats")) {
                    exportRow("apnea.ios.export.pdf", icon: "doc.fill", format: .pdf)
                    exportRow("apnea.ios.export.csv", icon: "tablecells", format: .csv)
                    exportRow("apnea.ios.export.json", icon: "curlybraces", format: .json)
                    exportRow("apnea.ios.export.gpx", icon: "map", format: .gpx)
                    exportRow("apnea.ios.export.chart", icon: "chart.xyaxis.line", format: .chartImage)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.export.cloud_backup")) {
                    Text(DIRIOSLocalizer.string(cloudCapability.localizationStatusKey))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.muted)
                    Text(DIRIOSLocalizer.string(cloudCapability.localizationNoteKey))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(DIRTheme.orange)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .overlay {
                if isExporting {
                    ProgressView(DIRIOSLocalizer.string("apnea.ios.export.generating"))
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.export.title"))
        .sheet(isPresented: $showShareSheet) {
            if let exportURL {
                ShareSheetView(activityItems: [exportURL])
            }
        }
    }

    private func exportRow(_ titleKey: String, icon: String, format: ApneaExportFormat) -> some View {
        Button {
            performExport(format: format)
        } label: {
            Label(DIRIOSLocalizer.string(titleKey), systemImage: icon)
                .foregroundStyle(DIRTheme.cyan)
        }
        .disabled(isExporting || !canExport(format: format))
    }

    private func canExport(format: ApneaExportFormat) -> Bool {
        if needsSensitiveConfirmation, (includeBuddyContact || includeEmergencyContact), !sensitiveAcknowledged {
            return false
        }
        if format == .gpx, needsLocationConfirmation, (!includeGPS || !locationAcknowledged) {
            return false
        }
        return true
    }

    private func performExport(format: ApneaExportFormat) {
        errorMessage = nil
        isExporting = true
        Task { @MainActor in
            defer { isExporting = false }
            do {
                let url = try IOSApneaSessionExportService.export(
                    session: session,
                    format: format,
                    options: privacyOptions
                )
                exportURL = url
                showShareSheet = true
            } catch IOSApneaSessionExportError.privacyConfirmationRequired {
                errorMessage = DIRIOSLocalizer.string("apnea.ios.export.error.privacy")
            } catch IOSApneaSessionExportError.gpxUnavailable {
                errorMessage = DIRIOSLocalizer.string("apnea.ios.export.error.gpx")
            } catch IOSApneaSessionExportError.emptyDataset {
                errorMessage = DIRIOSLocalizer.string("apnea.ios.export.error.empty")
            } catch {
                errorMessage = DIRIOSLocalizer.string("apnea.ios.export.error.generic")
            }
        }
    }
}
