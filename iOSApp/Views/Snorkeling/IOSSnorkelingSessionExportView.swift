import SwiftUI
import PhotosUI

struct IOSSnorkelingSessionExportView: View {
    let session: SnorkelingSession
    private let cloudCapability = SnorkelingCloudCapability.current
    @State private var locationPrecision: SnorkelingExportLocationPrecision = .removed
    @State private var includeBuddyContact = false
    @State private var includeEmergencyContact = false
    @State private var includeGroupContacts = false
    @State private var locationAcknowledged = false
    @State private var sensitiveAcknowledged = false
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var errorMessage: String?

    private var privacyOptions: SnorkelingExportPrivacyOptions {
        SnorkelingExportPrivacyOptions(
            locationPrecision: locationPrecision,
            includeBuddyContactDetails: includeBuddyContact,
            includeEmergencyContact: includeEmergencyContact,
            includeGroupContacts: includeGroupContacts,
            locationSharingAcknowledged: locationAcknowledged
        )
    }

    private var needsLocationConfirmation: Bool {
        SnorkelingExportPrivacyPolicy.requiresLocationConfirmation(for: session)
    }

    private var needsSensitiveConfirmation: Bool {
        SnorkelingExportPrivacyPolicy.requiresSensitiveDataConfirmation(for: session)
            || session.buddy != nil
    }

    var body: some View {
        DIRScreenContainer {
            List {
                if needsLocationConfirmation {
                    Section(DIRIOSLocalizer.string("snorkeling.ios.export.privacy")) {
                        Picker(DIRIOSLocalizer.string("snorkeling.ios.export.location_precision"), selection: $locationPrecision) {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.export.location_removed")).tag(SnorkelingExportLocationPrecision.removed)
                            Text(DIRIOSLocalizer.string("snorkeling.ios.export.location_reduced")).tag(SnorkelingExportLocationPrecision.reduced)
                            Text(DIRIOSLocalizer.string("snorkeling.ios.export.location_exact")).tag(SnorkelingExportLocationPrecision.exact)
                        }
                        if locationPrecision != .removed {
                            Toggle(DIRIOSLocalizer.string("snorkeling.ios.export.location_ack"), isOn: $locationAcknowledged)
                                .tint(DIRTheme.cyan)
                        }
                        Text(DIRIOSLocalizer.string("snorkeling.ios.export.privacy_note"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
                if needsSensitiveConfirmation {
                    Section(DIRIOSLocalizer.string("snorkeling.ios.export.sensitive")) {
                        Toggle(DIRIOSLocalizer.string("snorkeling.ios.export.include_buddy"), isOn: $includeBuddyContact)
                        Toggle(DIRIOSLocalizer.string("snorkeling.ios.export.include_emergency"), isOn: $includeEmergencyContact)
                        Toggle(DIRIOSLocalizer.string("snorkeling.ios.export.include_group"), isOn: $includeGroupContacts)
                        Toggle(DIRIOSLocalizer.string("snorkeling.ios.export.sensitive_ack"), isOn: $sensitiveAcknowledged)
                            .tint(DIRTheme.cyan)
                    }
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.export.formats")) {
                    exportRow("snorkeling.export.summary", icon: "doc.text", format: .summary)
                    exportRow("snorkeling.ios.export.pdf", icon: "doc.fill", format: .pdf)
                    exportRow("snorkeling.ios.export.csv", icon: "tablecells", format: .csv)
                    exportRow("snorkeling.ios.export.json", icon: "curlybraces", format: .json)
                    exportRow("snorkeling.export.gpx", icon: "map", format: .gpx)
                    exportRow("snorkeling.export.kml", icon: "globe.americas.fill", format: .kml)
                    exportRow("snorkeling.ios.export.chart", icon: "chart.xyaxis.line", format: .chartImage)
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.export.cloud_backup")) {
                    Text(DIRIOSLocalizer.string(cloudCapability.localizationStatusKey))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.muted)
                    Text(DIRIOSLocalizer.string(cloudCapability.localizationNoteKey))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.ios.export.cloud_backup"))
                .accessibilityValue(DIRIOSLocalizer.string(cloudCapability.localizationStatusKey))
                .accessibilityHint(DIRIOSLocalizer.string(cloudCapability.localizationNoteKey))

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(DIRTheme.orange)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .overlay {
                if isExporting {
                    ProgressView(DIRIOSLocalizer.string("snorkeling.ios.export.generating"))
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.export.title"))
        .sheet(isPresented: $showShareSheet) {
            if let exportURL {
                ShareSheetView(activityItems: [exportURL])
            }
        }
        .accessibilityIdentifier("snorkeling.ios.export")
    }

    private func exportRow(_ titleKey: String, icon: String, format: SnorkelingExportFormat) -> some View {
        Button {
            performExport(format: format)
        } label: {
            Label(DIRIOSLocalizer.string(titleKey), systemImage: icon)
                .foregroundStyle(DIRTheme.cyan)
        }
        .disabled(isExporting || !canExport(format: format))
    }

    private func canExport(format: SnorkelingExportFormat) -> Bool {
        if needsSensitiveConfirmation,
           (includeBuddyContact || includeEmergencyContact || includeGroupContacts),
           !sensitiveAcknowledged {
            return false
        }
        if format == .gpx || format == .kml,
           needsLocationConfirmation,
           !SnorkelingExportPrivacyPolicy.canExportLocation(options: privacyOptions, session: session) {
            return false
        }
        return true
    }

    private func performExport(format: SnorkelingExportFormat) {
        errorMessage = nil
        isExporting = true
        Task { @MainActor in
            defer { isExporting = false }
            do {
                let url = try IOSSnorkelingSessionExportService.export(
                    session: session,
                    format: format,
                    options: privacyOptions
                )
                exportURL = url
                showShareSheet = true
            } catch IOSSnorkelingSessionExportError.privacyConfirmationRequired {
                errorMessage = DIRIOSLocalizer.string("snorkeling.ios.export.error.privacy")
            } catch IOSSnorkelingSessionExportError.gpxUnavailable {
                errorMessage = DIRIOSLocalizer.string("snorkeling.ios.export.error.gpx")
            } catch IOSSnorkelingSessionExportError.kmlUnavailable {
                errorMessage = DIRIOSLocalizer.string("snorkeling.ios.export.error.gpx")
            } catch IOSSnorkelingSessionExportError.summaryUnavailable {
                errorMessage = DIRIOSLocalizer.string("snorkeling.ios.export.error.empty")
            } catch IOSSnorkelingSessionExportError.emptyDataset {
                errorMessage = DIRIOSLocalizer.string("snorkeling.ios.export.error.empty")
            } catch {
                errorMessage = DIRIOSLocalizer.string("snorkeling.ios.export.error.generic")
            }
        }
    }
}

struct IOSSnorkelingSessionPhotosView: View {
    let session: SnorkelingSession
    @EnvironmentObject private var photoStore: IOSSnorkelingSessionPhotoStore
    @State private var pickerItem: PhotosPickerItem?
    @State private var stripLocationMetadata = true
    @State private var selectedMarkerID: UUID?
    @State private var errorMessage: String?

    private var sessionPhotos: [SnorkelingSessionPhotoAttachment] {
        photoStore.attachments(for: session.id)
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    DIRCard(DIRIOSLocalizer.string("snorkeling.ios.photos.privacy"), accent: DIRTheme.cyan) {
                        Toggle(DIRIOSLocalizer.string("snorkeling.ios.photos.strip_location"), isOn: $stripLocationMetadata)
                            .tint(DIRTheme.cyan)
                        Text(DIRIOSLocalizer.string("snorkeling.ios.photos.privacy_note"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                    }

                    if !session.markers.isEmpty {
                        Picker(DIRIOSLocalizer.string("snorkeling.ios.photos.associate_marker"), selection: $selectedMarkerID) {
                            Text(DIRIOSLocalizer.string("snorkeling.ios.photos.session_only")).tag(UUID?.none)
                            ForEach(session.markers) { marker in
                                Text(markerLabel(marker)).tag(Optional(marker.id))
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(DIRIOSLocalizer.string("snorkeling.ios.photos.add"), systemImage: "photo.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(DIRTheme.cyan)
                            .background(
                                RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                                    .stroke(DIRTheme.cyan.opacity(0.35), lineWidth: 1)
                            )
                    }
                    .onChange(of: pickerItem) { _, item in
                        guard let item else { return }
                        Task { await importPhoto(from: item) }
                    }

                    if let errorMessage {
                        Text(errorMessage).font(.caption).foregroundStyle(DIRTheme.orange)
                    }

                    if sessionPhotos.isEmpty {
                        Text(DIRIOSLocalizer.string("snorkeling.ios.photos.empty"))
                            .foregroundStyle(DIRTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 24)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(sessionPhotos) { attachment in
                                photoTile(attachment)
                            }
                        }
                    }
                }
                .padding(18)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.photos.title"))
    }

    private func photoTile(_ attachment: SnorkelingSessionPhotoAttachment) -> some View {
        VStack(spacing: 6) {
            Group {
                if let image = photoStore.thumbnailImage(for: attachment) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        DIRTheme.surface
                        Image(systemName: "photo")
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Button {
                    photoStore.delete(id: attachment.id)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DIRTheme.orange)
                        .padding(4)
                }
                .accessibilityLabel(DIRIOSLocalizer.string("snorkeling.ios.photos.delete"))
            }
            if let markerID = attachment.markerID,
               let marker = session.markers.first(where: { $0.id == markerID }) {
                Text(markerLabel(marker))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .lineLimit(1)
            }
        }
    }

    private func importPhoto(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            _ = try photoStore.addPhoto(
                sessionID: session.id,
                markerID: selectedMarkerID,
                imageData: data,
                stripLocationMetadata: stripLocationMetadata
            )
            pickerItem = nil
            errorMessage = nil
        } catch {
            errorMessage = DIRIOSLocalizer.string("snorkeling.ios.photos.import_failed")
        }
    }

    private func markerLabel(_ marker: SnorkelingMarker) -> String {
        if marker.category == .custom, let label = marker.customCategoryLabel, !label.isEmpty {
            return label
        }
        switch marker.category {
        case .marineLife: return DIRIOSLocalizer.string("snorkeling.ios.marker.marine_life")
        case .reef: return DIRIOSLocalizer.string("snorkeling.ios.marker.reef")
        case .wreck: return DIRIOSLocalizer.string("snorkeling.ios.marker.wreck")
        case .photoSpot: return DIRIOSLocalizer.string("snorkeling.ios.marker.photo_spot")
        case .buoy: return DIRIOSLocalizer.string("snorkeling.ios.marker.buoy")
        case .custom: return DIRIOSLocalizer.string("snorkeling.ios.marker.custom")
        }
    }
}
