import SwiftUI
import Charts

enum RatioDecoPresentationColors {
    static let buhlmann = Color(red: 0x0A / 255, green: 0x84 / 255, blue: 0xFF / 255)
    static let ratioDeco = Color(red: 0xFF / 255, green: 0x9F / 255, blue: 0x0A / 255)
    static let violation = Color(red: 0xFF / 255, green: 0x45 / 255, blue: 0x3A / 255)
    static let gasSwitch = Color(red: 0x32 / 255, green: 0xD7 / 255, blue: 0x4B / 255)
}

struct RatioDecoDisclaimerBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(DIRTheme.cyan)
            Text(String(localized: "planner.ratio_deco.disclaimer"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.55)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "planner.ratio_deco.disclaimer"))
    }
}

struct PlannerDecompressionMethodPicker: View {
    @Binding var method: PlannerDecompressionMethod
    let mode: PlannerMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "planner.deco_method.header"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            Picker(String(localized: "planner.deco_method.header"), selection: $method) {
                ForEach(PlannerDecompressionMethod.allCases) { item in
                    Text(item.localizedTitle).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .tint(DIRTheme.cyan)
            .disabled(mode == .base)
            if mode == .base {
                Text(String(localized: "planner.ratio_deco.validation.unavailable_base"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
            } else if method != .buhlmann {
                Text(String(localized: "planner.ratio_deco.subtitle"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }
}

struct RatioDecoPresetCard: View {
    @EnvironmentObject private var store: PlannerStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var showSaveSheet = false
    @State private var presetDraft = RatioDecoPreset.customDefault

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var selectablePresets: [RatioDecoPreset] {
        [.preset1to1, .preset2to1, .customDefault] + store.savedRatioDecoPresets
    }

    var body: some View {
        DIRCard(String(localized: "planner.ratio_deco.profile.header"), icon: "slider.horizontal.3", accent: DIRTheme.orange) {
            Picker(String(localized: "planner.ratio_deco.profile.header"), selection: presetIDBinding) {
                ForEach(selectablePresets) { preset in
                    Text(preset.name).tag(preset.id)
                }
            }
            .pickerStyle(.menu)
            .tint(DIRTheme.cyan)

            if store.ratioDecoPreset.id == RatioDecoPreset.customPresetID
                || !store.ratioDecoPreset.isBuiltIn {
                customPresetFields
            }

            HStack(spacing: 8) {
                Button(String(localized: "planner.ratio_deco.save_preset")) {
                    presetDraft = store.ratioDecoPreset
                    if presetDraft.isBuiltIn {
                        presetDraft = RatioDecoPreset.customDefault
                        presetDraft.id = UUID()
                        presetDraft.name = String(localized: "planner.ratio_deco.preset.custom")
                    }
                    showSaveSheet = true
                }
                .buttonStyle(.bordered)
                .tint(DIRTheme.cyan)

                if !store.ratioDecoPreset.isBuiltIn,
                   store.savedRatioDecoPresets.contains(where: { $0.id == store.ratioDecoPreset.id }) {
                    Button(String(localized: "planner.ratio_deco.delete_preset"), role: .destructive) {
                        store.deleteRatioDecoPreset(id: store.ratioDecoPreset.id)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            NavigationStack {
                Form {
                    Section(String(localized: "planner.ratio_deco.save_preset")) {
                        TextField(String(localized: "planner.ratio_deco.preset.name"), text: $presetDraft.name)
                    }
                    Section {
                        Button(String(localized: "planner.ratio_deco.save_preset")) {
                            store.saveRatioDecoPreset(presetDraft)
                            showSaveSheet = false
                        }
                    }
                }
                .navigationTitle(String(localized: "planner.ratio_deco.edit_preset"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "pdf.export.cancel")) { showSaveSheet = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var presetIDBinding: Binding<UUID> {
        Binding(
            get: { store.ratioDecoPreset.id },
            set: { id in
                if let preset = selectablePresets.first(where: { $0.id == id }) {
                    store.ratioDecoPreset = preset
                }
            }
        )
    }

    private func presetBinding<T>(_ keyPath: WritableKeyPath<RatioDecoPreset, T>) -> Binding<T> {
        Binding(
            get: { store.ratioDecoPreset[keyPath: keyPath] },
            set: { newValue in
                var preset = store.ratioDecoPreset
                preset[keyPath: keyPath] = newValue
                store.ratioDecoPreset = preset
            }
        )
    }

    private var customPresetFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker(String(localized: "planner.ratio_deco.ratio.header"), selection: presetBinding(\.ratioType)) {
                ForEach(RatioDecoRatioType.allCases) { type in
                    Text(type.localizedTitle).tag(type)
                }
            }
            .pickerStyle(.segmented)

            if store.ratioDecoPreset.ratioType == .custom {
                Stepper(
                    value: presetBinding(\.customRatioDenominator),
                    in: 0.5...5,
                    step: 0.1
                ) {
                    Text(
                        String(
                            format: String(localized: "planner.ratio_deco.ratio.custom_value"),
                            Formatters.one(store.ratioDecoPreset.customRatioDenominator)
                        )
                    )
                    .font(.caption)
                }
            }

            depthStepper(
                title: String(localized: "planner.ratio_deco.first_stop"),
                value: presetBinding(\.firstStopDepthMeters),
                range: 3...60,
                step: store.ratioDecoPreset.stopStepMeters
            )
            depthStepper(
                title: String(localized: "planner.ratio_deco.stop_step"),
                value: presetBinding(\.stopStepMeters),
                range: 3...9,
                step: 3
            )
            Stepper(
                value: presetBinding(\.minimumStopMinutes),
                in: 1...10,
                step: 1
            ) {
                Text(
                    String(
                        format: String(localized: "planner.ratio_deco.minimum_stop_value"),
                        Int(store.ratioDecoPreset.minimumStopMinutes.rounded())
                    )
                )
                .font(.caption)
            }
            Picker(String(localized: "planner.ratio_deco.distribution.header"), selection: presetBinding(\.distributionMode)) {
                ForEach(RatioDecoDistributionMode.allCases) { mode in
                    Text(mode.localizedTitle).tag(mode)
                }
            }
            Toggle(String(localized: "planner.ratio_deco.deep_stops"), isOn: presetBinding(\.deepStopsEnabled))
                .tint(DIRTheme.cyan)
        }
    }

    private func depthStepper(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        Stepper(value: value, in: range, step: step) {
            Text("\(title): \(Formatters.depth(value.wrappedValue, units: unitPreference).text)")
                .font(.caption)
        }
    }
}

struct RatioDecoComparisonSection: View {
    @EnvironmentObject private var store: PlannerStore
    let unitPreference: IOSUnitPreference

    private var bundle: RatioDecoPlanningBundle? { store.plan.ratioDeco }

    var body: some View {
        if let bundle {
            RatioDecoDisclaimerBanner()
            validationSummary(bundle.validation)
            summaryCards(bundle: bundle)
            comparisonTables(bundle: bundle)
            if store.decompressionMethod == .comparison {
                RatioDecoOverlayProfileChart(
                    buhlmannPoints: store.plan.depthProfilePoints,
                    ratioDecoPoints: bundle.schedule.depthProfilePoints,
                    unitPreference: unitPreference
                )
            } else {
                ratioDecoScheduleCard(bundle.schedule)
            }
        }
    }

    @ViewBuilder
    private func validationSummary(_ validation: RatioDecoValidationResult) -> some View {
        let color = validationStatusColor(validation)
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: validation.isBuhlmannCompatible ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(validation.localizedStatusTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                if !validation.isBuhlmannCompatible {
                    Text(String(localized: "planner.ratio_deco.validation.not_validated_plan"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(RatioDecoPresentationColors.violation)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(Array(validation.warnings.enumerated()), id: \.offset) { _, warning in
                    Text(localizedValidationWarning(warning))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(validation.localizedStatusTitle)
    }

    private func summaryCards(bundle: RatioDecoPlanningBundle) -> some View {
        HStack(spacing: 0) {
            DIRMetricTile(
                title: String(localized: "planner.ratio_deco.summary.buhlmann_tts"),
                value: "\(store.plan.ttsMinutes)",
                unit: "min"
            )
            Divider().overlay(DIRTheme.hairline)
            DIRMetricTile(
                title: String(localized: "planner.ratio_deco.summary.ratio_tts"),
                value: "\(bundle.schedule.ttsMinutes)",
                unit: "min"
            )
            Divider().overlay(DIRTheme.hairline)
            DIRMetricTile(
                title: String(localized: "planner.ratio_deco.summary.tts_difference"),
                value: "\(bundle.schedule.ttsMinutes - store.plan.ttsMinutes)",
                unit: "min",
                color: bundle.schedule.ttsMinutes > store.plan.ttsMinutes ? DIRTheme.yellow : DIRTheme.green
            )
        }
    }

    private func comparisonTables(bundle: RatioDecoPlanningBundle) -> some View {
        Group {
            if store.decompressionMethod == .comparison {
                DIRCard(String(localized: "planner.ratio_deco.comparison.title"), icon: "arrow.left.arrow.right", accent: DIRTheme.cyan) {
                    Text(String(localized: "planner.ratio_deco.comparison.buhlmann"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RatioDecoPresentationColors.buhlmann)
                    buhlmannStopTable
                    Text(String(localized: "planner.ratio_deco.comparison.ratio_deco"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RatioDecoPresentationColors.ratioDeco)
                        .padding(.top, 8)
                    ratioDecoStopTable(bundle.schedule)
                }
            }
        }
    }

    private func ratioDecoScheduleCard(_ schedule: RatioDecoSchedule) -> some View {
        DIRCard(String(localized: "planner.ratio_deco.schedule.title"), icon: "timer", accent: DIRTheme.orange) {
            Text(
                String(
                    format: String(localized: "planner.ratio_deco.preset_line"),
                    schedule.presetName
                )
            )
            .font(.caption2)
            .foregroundStyle(DIRTheme.muted)
            ratioDecoStopTable(schedule)
        }
    }

    private var buhlmannStopTable: some View {
        stopTable(
            rows: buhlmannComparisonRows,
            accent: RatioDecoPresentationColors.buhlmann
        )
    }

    private func ratioDecoStopTable(_ schedule: RatioDecoSchedule) -> some View {
        stopTable(
            rows: schedule.stops.map {
                RatioDecoComparisonRow(
                    depthLabel: Formatters.depth($0.depthMeters, units: unitPreference).text,
                    timeLabel: "\(Int($0.durationMinutes.rounded())) min",
                    gasLabel: $0.gasLabel,
                    runtimeLabel: Formatters.one($0.runtimeMinute)
                )
            },
            accent: RatioDecoPresentationColors.ratioDeco
        )
    }

    private var buhlmannComparisonRows: [RatioDecoComparisonRow] {
        var cumulative = 0.0
        var rows: [RatioDecoComparisonRow] = []
        for row in store.plan.ascentTableRows {
            cumulative += row.minutes
            guard row.kind == .decoStop else { continue }
            rows.append(
                RatioDecoComparisonRow(
                    depthLabel: row.depthLabel,
                    timeLabel: row.timeLabel,
                    gasLabel: row.gas,
                    runtimeLabel: Formatters.one(cumulative)
                )
            )
        }
        return rows
    }

    private func stopTable(rows: [RatioDecoComparisonRow], accent: Color) -> some View {
        VStack(spacing: 0) {
            comparisonHeader
            if rows.isEmpty {
                Text(String(localized: "planner.export.no_deco_stops"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack(spacing: 8) {
                        Text(row.depthLabel).frame(maxWidth: .infinity, alignment: .leading)
                        Text(row.timeLabel).frame(width: 56, alignment: .trailing)
                        Text(row.gasLabel).frame(maxWidth: .infinity, alignment: .leading)
                        Text(row.runtimeLabel).frame(width: 52, alignment: .trailing)
                    }
                    .font(.caption2)
                    .foregroundStyle(accent)
                    .padding(.vertical, 6)
                    if index < rows.count - 1 {
                        Divider().overlay(DIRTheme.hairline)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: DIRTheme.compactRadius).fill(DIRTheme.surface2.opacity(0.45)))
    }

    private var comparisonHeader: some View {
        HStack(spacing: 8) {
            Text(String(localized: "planner.table.depth")).frame(maxWidth: .infinity, alignment: .leading)
            Text(String(localized: "planner.table.time")).frame(width: 56, alignment: .trailing)
            Text(String(localized: "planner.table.gas")).frame(maxWidth: .infinity, alignment: .leading)
            Text(String(localized: "planner.table.runtime")).frame(width: 52, alignment: .trailing)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(DIRTheme.muted)
        .padding(.vertical, 6)
    }

    private func validationStatusColor(_ validation: RatioDecoValidationResult) -> Color {
        if validation.warnings.contains(where: {
            if case .ceilingViolation = $0 { return true }
            return false
        }) {
            return RatioDecoPresentationColors.violation
        }
        if validation.isBuhlmannCompatible {
            return DIRTheme.green
        }
        return DIRTheme.yellow
    }

    private func localizedValidationWarning(_ warning: RatioDecoValidationWarning) -> String {
        switch warning {
        case .unavailableInBaseMode:
            return String(localized: "planner.ratio_deco.validation.unavailable_base")
        case .ceilingViolation:
            return String(localized: "planner.ratio_deco.validation.ceiling")
        case .modExceeded:
            return String(localized: "planner.ratio_deco.validation.mod")
        case .decoDepthLimitExceeded:
            return String(localized: "planner.mode.deco.depth_limit.message")
        }
    }
}

private struct RatioDecoComparisonRow {
    let depthLabel: String
    let timeLabel: String
    let gasLabel: String
    let runtimeLabel: String
}

struct RatioDecoOverlayProfileChart: View {
    let buhlmannPoints: [DepthProfilePoint]
    let ratioDecoPoints: [DepthProfilePoint]
    let unitPreference: IOSUnitPreference

    private var yAxisLabel: String {
        unitPreference == .metric
            ? String(localized: "planner.charts.depth_axis_unit_metric")
            : String(localized: "planner.charts.depth_axis_unit_imperial")
    }

    var body: some View {
        DIRCard(String(localized: "planner.ratio_deco.overlay.title"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
            if buhlmannPoints.isEmpty && ratioDecoPoints.isEmpty {
                Text(String(localized: "planner.charts.depth_profile_empty"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            } else {
                Chart {
                    ForEach(buhlmannPoints) { point in
                        LineMark(
                            x: .value(String(localized: "planner.buhlmann.axis.time"), point.elapsedMinutes),
                            y: .value(yAxisLabel, displayDepth(point.depthMeters)),
                            series: .value("Series", "Bühlmann")
                        )
                        .foregroundStyle(RatioDecoPresentationColors.buhlmann)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    ForEach(ratioDecoPoints) { point in
                        LineMark(
                            x: .value(String(localized: "planner.buhlmann.axis.time"), point.elapsedMinutes),
                            y: .value(yAxisLabel, displayDepth(point.depthMeters)),
                            series: .value("Series", "Ratio Deco")
                        )
                        .foregroundStyle(RatioDecoPresentationColors.ratioDeco)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    }
                }
                .chartForegroundStyleScale([
                    "Bühlmann": RatioDecoPresentationColors.buhlmann,
                    "Ratio Deco": RatioDecoPresentationColors.ratioDeco
                ])
                .chartXAxisLabel(String(localized: "planner.buhlmann.axis.time"))
                .chartYAxisLabel(yAxisLabel)
                .frame(minHeight: 160, maxHeight: 280)
                HStack(spacing: 12) {
                    legendItem(color: RatioDecoPresentationColors.buhlmann, label: String(localized: "planner.deco_method.buhlmann"))
                    legendItem(color: RatioDecoPresentationColors.ratioDeco, label: String(localized: "planner.deco_method.ratio_deco"))
                }
                .font(.caption2)
            }
        }
    }

    private func displayDepth(_ meters: Double) -> Double {
        -Formatters.depthValue(meters, units: unitPreference)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundStyle(DIRTheme.muted)
        }
    }
}
