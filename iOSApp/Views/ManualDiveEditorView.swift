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
    @State private var ccrRebreatherModel = ""
    @State private var ccrLowSetpoint = 0.7
    @State private var ccrHighSetpoint = 1.3
    @State private var ccrSetpointSwitchDepthInput = ManualDiveEditorDefaults.defaultCCRSetpointSwitchDepthInput(units: .metric)
    @State private var ccrDiluentLabel = "AIR"
    @State private var ccrBailoutLabels = ""
    @State private var ccrScrubberNotes = ""
    @State private var ccrOxygenSensorNotes = ""
    @State private var ccrLoopNotes = ""
    @State private var ccrBailoutScenarioNotes = ""
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
        DIRScreenContainer {
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
                    if gasLabel == .ccr {
                        ccrMetadataSection
                    }
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
            .dirCompanionScrollSurface()
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
        .onChange(of: units) { _, newUnits in
            let preference = IOSUnitPreference.fromStorage(newUnits)
            if existing == nil {
                applyDefaultDepthInputs()
            } else if gasLabel == .ccr {
                let meters = ManualDiveEditorDefaults.depthMeters(fromInput: ccrSetpointSwitchDepthInput, units: unitPreference)
                ccrSetpointSwitchDepthInput = Formatters.depthValue(meters, units: preference)
            }
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

    private var ccrMetadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "manual_dive.ccr.header"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.orange)
            field(String(localized: "ccr.rebreather_model"), text: $ccrRebreatherModel)
            stepperField(String(localized: "ccr.setpoint.low"), value: $ccrLowSetpoint, suffix: "bar", step: 0.1, range: 0.4...1.6)
            stepperField(String(localized: "ccr.setpoint.high"), value: $ccrHighSetpoint, suffix: "bar", step: 0.1, range: 0.4...1.6)
            stepperField(String(localized: "ccr.setpoint.switch_depth"), value: $ccrSetpointSwitchDepthInput, suffix: unitPreference == .metric ? "m" : "ft", step: 1, range: 0...120)
            field(String(localized: "manual_dive.ccr.diluent_label"), text: $ccrDiluentLabel)
            field(String(localized: "manual_dive.ccr.bailout_labels"), text: $ccrBailoutLabels)
            field(String(localized: "manual_dive.ccr.scrubber_notes"), text: $ccrScrubberNotes)
            field(String(localized: "manual_dive.ccr.o2_sensor_notes"), text: $ccrOxygenSensorNotes)
            field(String(localized: "manual_dive.ccr.loop_notes"), text: $ccrLoopNotes)
            field(String(localized: "manual_dive.ccr.bailout_scenario_notes"), text: $ccrBailoutScenarioNotes)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.orange.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.orange.opacity(0.35), lineWidth: 1))
        )
    }

    private var currentCCRMetadata: CCRLogbookMetadata? {
        guard gasLabel == .ccr else { return nil }
        return CCRLogbookMetadata(
            rebreatherModel: ccrRebreatherModel,
            lowSetpoint: ccrLowSetpoint,
            highSetpoint: ccrHighSetpoint,
            setpointSwitchDepthMeters: ManualDiveEditorDefaults.depthMeters(fromInput: ccrSetpointSwitchDepthInput, units: unitPreference),
            diluentLabel: ccrDiluentLabel,
            bailoutLabels: ccrBailoutLabels
                .split(separator: "|")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty },
            scrubberNotes: ccrScrubberNotes,
            oxygenSensorNotes: ccrOxygenSensorNotes,
            loopNotes: ccrLoopNotes,
            bailoutScenarioNotes: ccrBailoutScenarioNotes
        )
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
        ccrSetpointSwitchDepthInput = ManualDiveEditorDefaults.defaultCCRSetpointSwitchDepthInput(units: unitPreference)
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
        if let entryBar = existing.entryPressureBar {
            entryPressureText = PressureDisplayMath.formatPressureValue(entryBar, units: unitPreference)
        } else {
            entryPressureText = existing.entryPressureText ?? ""
        }
        if let exitBar = existing.exitPressureBar {
            exitPressureText = PressureDisplayMath.formatPressureValue(exitBar, units: unitPreference)
        } else {
            exitPressureText = existing.exitPressureText ?? ""
        }
        decompressionNotes = existing.decompressionNotes ?? ""
        notes = existing.notes ?? ""
        gasLabel = existing.gasLabel
        if let ccr = existing.ccrLogbookMetadata {
            ccrRebreatherModel = ccr.rebreatherModel
            ccrLowSetpoint = ccr.lowSetpoint
            ccrHighSetpoint = ccr.highSetpoint
            ccrSetpointSwitchDepthInput = Formatters.depthValue(ccr.setpointSwitchDepthMeters, units: unitPreference)
            ccrDiluentLabel = ccr.diluentLabel
            ccrBailoutLabels = ccr.bailoutLabels.joined(separator: " | ")
            ccrScrubberNotes = ccr.scrubberNotes
            ccrOxygenSensorNotes = ccr.oxygenSensorNotes
            ccrLoopNotes = ccr.loopNotes
            ccrBailoutScenarioNotes = ccr.bailoutScenarioNotes
        }
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
        if gasLabel == .ccr, let metadata = currentCCRMetadata,
           let error = ManualDiveEditorValidation.ccrMetadataError(metadata: metadata, maxDepthMeters: existing.maxDepthMeters) {
            validationMessage = error
            return
        }
        let duration = durationMinutes * 60
        let endDate = startDate.addingTimeInterval(duration)
        let entryGPS = ManualDiveEditorValidation.makeGPSPoint(lat: entryLatitude, lon: entryLongitude, timestamp: startDate)
        let exitGPS = ManualDiveEditorValidation.makeGPSPoint(lat: exitLatitude, lon: exitLongitude, timestamp: endDate)
        let pressures = ManualDiveEditorValidation.parsedManualPressures(
            entryPressureText: entryPressureText,
            exitPressureText: exitPressureText,
            unitPreference: unitPreference
        )
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
            entryPressureText: pressures.entryText,
            exitPressureText: pressures.exitText,
            entryPressureBar: pressures.entryBar,
            exitPressureBar: pressures.exitBar,
            decompressionNotes: decompressionNotes.isEmpty ? nil : decompressionNotes,
            ccrLogbookMetadata: currentCCRMetadata
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
        switch ManualDiveEditorValidation.makeSyntheticSession(
            existing: existing,
            startDate: startDate,
            durationMinutes: durationMinutes,
            maxMeters: maxMeters,
            avgMeters: avgMeters,
            siteName: siteName,
            entryLatitude: entryLatitude,
            entryLongitude: entryLongitude,
            exitLatitude: exitLatitude,
            exitLongitude: exitLongitude,
            equipmentUsed: equipmentUsed,
            entryPressureText: entryPressureText,
            exitPressureText: exitPressureText,
            decompressionNotes: decompressionNotes,
            notes: notes,
            gasLabel: gasLabel,
            ccrLogbookMetadata: currentCCRMetadata,
            unitPreference: unitPreference
        ) {
        case .failure(let error):
            validationMessage = error.errorDescription
        case .success(let session):
            guard logStore.add(session) else {
                showSaveFailureAlert = true
                return
            }
            dismiss()
        }
    }
}
