import SwiftUI

struct ManualDiveEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var logStore: DiveLogStore
    @AppStorage(IOSUnitPreference.storageKey) private var units = IOSUnitPreference.metric.rawValue

    let existing: DiveSession?

    @State private var siteName = ""
    @State private var startDate = Date()
    @State private var durationMinutes = 45.0
    @State private var maxDepthInput = ManualDiveEditorDefaults.defaultMaxDepthInput(units: .metric)
    @State private var avgDepthInput = ManualDiveEditorDefaults.defaultAverageDepthInput(units: .metric)
    @State private var entryLatitude = ""
    @State private var entryLongitude = ""
    @State private var exitLatitude = ""
    @State private var exitLongitude = ""
    @State private var equipmentUsed = ""
    @State private var entryPressureText = ""
    @State private var exitPressureText = ""
    @State private var decompressionNotes = ""
    @State private var notes = ""
    @State private var gasLabel: DiveGasLabel = .oc
    @State private var validationMessage: String?
    @State private var showSaveFailureAlert = false

    init(existing: DiveSession? = nil) {
        self.existing = existing
    }

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(units) }

    private var isMetadataOnlyEditMode: Bool {
        guard let existing else { return false }
        return existing.isManual && !existing.hasDepthProfile
    }

    private var showsSyntheticProfileDisclosure: Bool {
        !isMetadataOnlyEditMode
    }

    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if isMetadataOnlyEditMode {
                        metadataOnlyBanner
                    } else if showsSyntheticProfileDisclosure {
                        syntheticProfileDisclosure
                    }
                    field(String(localized: "manual_dive.site"), text: $siteName)
                    DatePicker(String(localized: "manual_dive.start"), selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        .tint(DIRTheme.cyan)
                    stepperField(String(localized: "manual_dive.duration"), value: $durationMinutes, suffix: "min", step: 5, range: 5...300)
                    if !isMetadataOnlyEditMode {
                        stepperField(String(localized: "manual_dive.max_depth"), value: $maxDepthInput, suffix: unitPreference == .metric ? "m" : "ft", step: 1, range: 1...120)
                        stepperField(String(localized: "manual_dive.avg_depth"), value: $avgDepthInput, suffix: unitPreference == .metric ? "m" : "ft", step: 1, range: 1...120)
                    }
                    field(String(localized: "manual_dive.entry_lat"), text: $entryLatitude, keyboard: .decimalPad)
                    field(String(localized: "manual_dive.entry_lon"), text: $entryLongitude, keyboard: .decimalPad)
                    field(String(localized: "manual_dive.exit_lat"), text: $exitLatitude, keyboard: .decimalPad)
                    field(String(localized: "manual_dive.exit_lon"), text: $exitLongitude, keyboard: .decimalPad)
                    field(String(localized: "manual_dive.equipment"), text: $equipmentUsed)
                    field(String(localized: "manual_dive.entry_pressure"), text: $entryPressureText)
                    field(String(localized: "manual_dive.exit_pressure"), text: $exitPressureText)
                    field(String(localized: "manual_dive.deco_notes"), text: $decompressionNotes)
                    field(String(localized: "manual_dive.notes"), text: $notes)
                    Picker(String(localized: "manual_dive.gas"), selection: $gasLabel) {
                        ForEach(DiveGasLabel.allCases) { gas in
                            Text(gas.rawValue).tag(gas)
                        }
                    }
                    .pickerStyle(.segmented)
                    if let validationMessage {
                        Text(validationMessage)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.red)
                    }
                    Button {
                        save()
                    } label: {
                        Text(String(localized: "manual_dive.save"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.cyan))
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
        }
        .navigationTitle(existing == nil ? String(localized: "manual_dive.add.title") : String(localized: "manual_dive.edit.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(String(localized: "manual_dive.cancel")) { dismiss() }
                    .foregroundStyle(DIRTheme.muted)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "manual_dive.save")) { save() }
                    .foregroundStyle(DIRTheme.cyan)
            }
        }
        .onAppear {
            if existing == nil {
                applyDefaultDepthInputs()
            } else {
                loadExisting()
            }
        }
        .onChange(of: units) { _, _ in
            guard existing == nil else { return }
            applyDefaultDepthInputs()
        }
        .alert(String(localized: "manual_dive.save_failed.title"), isPresented: $showSaveFailureAlert) {
            Button(String(localized: "manual_dive.save_failed.dismiss"), role: .cancel) {}
        } message: {
            Text(String(localized: "manual_dive.save_failed.message"))
        }
    }

    private var metadataOnlyBanner: some View {
        Text(String(localized: "manual_dive.edit.nodepth.banner"))
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DIRTheme.cyan.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.55), lineWidth: 1))
            )
            .accessibilityLabel(String(localized: "manual_dive.edit.nodepth.banner"))
    }

    private var syntheticProfileDisclosure: some View {
        Text(String(localized: "manual_dive.synthetic_profile.disclosure"))
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.yellow)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DIRTheme.yellow.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.yellow.opacity(0.45), lineWidth: 1))
            )
            .accessibilityLabel(String(localized: "manual_dive.synthetic_profile.disclosure"))
    }

    private func field(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(DIRTheme.muted)
            TextField(title, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.plain)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2))
                .foregroundStyle(.white)
        }
    }

    private func stepperField(_ title: String, value: Binding<Double>, suffix: String, step: Double, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(DIRTheme.muted)
            HStack {
                Button("-") { value.wrappedValue = max(range.lowerBound, value.wrappedValue - step) }
                    .accessibilityLabel(String(format: String(localized: "manual_dive.stepper.decrease.a11y"), title))
                Spacer()
                Text("\(Formatters.one(value.wrappedValue)) \(suffix)")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .accessibilityLabel(String(format: String(localized: "manual_dive.stepper.value.a11y"), title, Formatters.one(value.wrappedValue), suffix))
                Spacer()
                Button("+") { value.wrappedValue = min(range.upperBound, value.wrappedValue + step) }
                    .accessibilityLabel(String(format: String(localized: "manual_dive.stepper.increase.a11y"), title))
            }
            .font(.callout.weight(.bold))
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2))
            .foregroundStyle(DIRTheme.cyan)
            .buttonStyle(.plain)
        }
    }

    private func applyDefaultDepthInputs() {
        maxDepthInput = ManualDiveEditorDefaults.defaultMaxDepthInput(units: unitPreference)
        avgDepthInput = ManualDiveEditorDefaults.defaultAverageDepthInput(units: unitPreference)
    }

    private func loadExisting() {
        guard let existing else { return }
        siteName = existing.siteName ?? ""
        startDate = existing.startDate
        durationMinutes = existing.durationSeconds / 60
        maxDepthInput = Formatters.depthValue(existing.maxDepthMeters, units: unitPreference)
        avgDepthInput = Formatters.depthValue(existing.avgDepthMeters, units: unitPreference)
        entryLatitude = existing.entryGPS.map { String($0.latitude) } ?? ""
        entryLongitude = existing.entryGPS.map { String($0.longitude) } ?? ""
        exitLatitude = existing.exitGPS.map { String($0.latitude) } ?? ""
        exitLongitude = existing.exitGPS.map { String($0.longitude) } ?? ""
        equipmentUsed = existing.equipmentUsed ?? ""
        entryPressureText = existing.entryPressureText ?? ""
        exitPressureText = existing.exitPressureText ?? ""
        decompressionNotes = existing.decompressionNotes ?? ""
        notes = existing.notes ?? ""
        gasLabel = existing.gasLabel
    }

    private func save() {
        if isMetadataOnlyEditMode {
            saveMetadataOnly()
        } else {
            saveWithSyntheticProfile()
        }
    }

    private func saveMetadataOnly() {
        guard let existing else { return }
        let duration = durationMinutes * 60
        let endDate = startDate.addingTimeInterval(duration)
        let entryGPS = makeGPS(lat: entryLatitude, lon: entryLongitude, timestamp: startDate)
        let exitGPS = makeGPS(lat: exitLatitude, lon: exitLongitude, timestamp: endDate)
        let session = DiveSession(
            id: existing.id,
            startDate: startDate,
            endDate: endDate,
            durationSeconds: duration,
            maxDepthMeters: existing.maxDepthMeters,
            avgDepthMeters: existing.avgDepthMeters,
            avgWaterTemperatureCelsius: existing.avgWaterTemperatureCelsius,
            ttv: existing.ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            entryGPSFixSource: existing.entryGPSFixSource,
            exitGPSFixSource: existing.exitGPSFixSource,
            samples: [],
            siteName: siteName.isEmpty ? String(localized: "manual_dive.default_site") : siteName,
            buddy: existing.buddy,
            notes: notes.isEmpty ? nil : notes,
            gasLabel: gasLabel,
            sacLitersMinute: existing.sacLitersMinute,
            isDemo: existing.isDemo,
            exceededSupportedDepthRange: existing.exceededSupportedDepthRange,
            isManual: true,
            hasDepthProfile: false,
            equipmentUsed: equipmentUsed.isEmpty ? nil : equipmentUsed,
            entryPressureText: entryPressureText.isEmpty ? nil : entryPressureText,
            exitPressureText: exitPressureText.isEmpty ? nil : exitPressureText,
            decompressionNotes: decompressionNotes.isEmpty ? nil : decompressionNotes
        )
        guard logStore.add(session) else {
            showSaveFailureAlert = true
            return
        }
        dismiss()
    }

    private func saveWithSyntheticProfile() {
        let maxMeters = ManualDiveEditorDefaults.depthMeters(fromInput: maxDepthInput, units: unitPreference)
        let avgMeters = ManualDiveEditorDefaults.depthMeters(fromInput: avgDepthInput, units: unitPreference)
        guard maxMeters >= avgMeters else {
            validationMessage = String(localized: "manual_dive.validation.depth_order")
            return
        }
        let duration = durationMinutes * 60
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
            entryPressureText: entryPressureText.isEmpty ? nil : entryPressureText,
            exitPressureText: exitPressureText.isEmpty ? nil : exitPressureText,
            decompressionNotes: decompressionNotes.isEmpty ? nil : decompressionNotes
        )
        guard logStore.add(session) else {
            showSaveFailureAlert = true
            return
        }
        dismiss()
    }

    private func makeGPS(lat: String, lon: String, timestamp: Date) -> GPSPoint? {
        guard let latitude = Double(lat.replacingOccurrences(of: ",", with: ".")),
              let longitude = Double(lon.replacingOccurrences(of: ",", with: ".")) else { return nil }
        let point = GPSPoint(latitude: latitude, longitude: longitude, horizontalAccuracy: 10, timestamp: timestamp)
        return DiveProfileMath.isValidGPS(point) ? point : nil
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
