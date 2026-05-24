import SwiftUI
import Charts

struct PlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    @AppStorage(PlannerSafetyAcknowledgment.storageKey) private var plannerSafetyAckRevision = ""
    @State private var showPlan = false

    private var plannerSafetyAcknowledged: Bool {
        plannerSafetyAckRevision == PlannerSafetyAcknowledgment.currentRevision
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(String(localized: "Planner"))
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(String(localized: "planner.header.subtitle"))
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        plannerSafetyAcknowledgment
                        DIRWarningBox(text: String(localized: "planner.units.metric_notice"))
                        Group {
                            modePicker
                            profileCard
                            plannerCylindersCard
                            technicalAnalysisCard
                            reserveCard
                            teamPreviewCard
                            plannerMODInputWarnings
                            plannerWarnings
                            calculateButton
                        }
                        .disabled(!plannerSafetyAcknowledged)
                        .opacity(plannerSafetyAcknowledged ? 1 : 0.45)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showPlan) {
                PlanResultView()
                    .environmentObject(store)
            }
            .onAppear {
                if store.mode != .advanced {
                    store.mode = .advanced
                }
                store.input.ensurePlannerCylindersFromLegacy()
            }
        }
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "planner.mode.header"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 0) {
                ForEach(PlannerMode.allCases) { mode in
                    let isActive = mode == .advanced
                    Button {
                        guard isActive else { return }
                        store.mode = mode
                    } label: {
                        Text(plannerModeTabLabel(mode))
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .foregroundStyle(store.mode == mode && isActive ? .black : .white.opacity(isActive ? 0.92 : 0.45))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(store.mode == mode && isActive ? DIRTheme.cyan : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isActive)
                    .accessibilityLabel(plannerModeAccessibilityLabel(mode, isActive: isActive))
                }
            }
            .padding(4)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.82)))
            Text(String(localized: "planner.mode.footer"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.yellow)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func plannerModeAccessibilityLabel(_ mode: PlannerMode, isActive: Bool) -> String {
        let name = plannerModeTabLabel(mode)
        if isActive {
            return String(format: String(localized: "planner.mode.a11y.active"), name)
        }
        return String(format: String(localized: "planner.mode.a11y.planned"), name)
    }

    private func salinityLabel(_ mode: SalinityMode) -> String {
        switch mode {
        case .fresh: return String(localized: "salinity.fresh")
        case .salt: return String(localized: "salinity.salt")
        }
    }

    /// Display-only labels for the segmented control. `PlannerMode` raw values stay unchanged for Codable persistence.
    private func plannerModeTabLabel(_ mode: PlannerMode) -> String {
        switch mode {
        case .recreational: return String(localized: "Semplice")
        case .advanced: return String(localized: "Avanzato")
        case .technical: return String(localized: "Tecnico")
        case .overhead: return String(localized: "Overhead")
        }
    }

    private var profileCard: some View {
        DIRCard(String(localized: "planner.profile.title"), icon: nil, accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                plannerField(String(localized: "planner.field.max_depth"), value: $store.input.plannedDepthMeters, unit: "m", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.avg_depth"), value: $store.input.plannedAverageDepthMeters, unit: "m", step: 1)
                Divider().overlay(DIRTheme.hairline)
                HStack {
                    Text(String(localized: "planner.field.planning_reference"))
                        .font(.callout)
                        .foregroundStyle(.white)
                    Spacer()
                    Picker(String(localized: "planner.field.planning_reference"), selection: $store.input.planningDepthReference) {
                        Text(String(localized: "planner.reference.max_depth")).tag(PlanningDepthReference.maximumDepth)
                        Text(String(localized: "planner.reference.avg_depth")).tag(PlanningDepthReference.averageDepth)
                    }
                    .labelsHidden()
                    .tint(DIRTheme.cyan)
                }
                .padding(.vertical, 10)
                Divider().overlay(DIRTheme.hairline)
                DIRWarningBox(text: String(localized: "planner.emergency_gas.max_depth_rule"))
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.bottom_time"), value: $store.input.plannedBottomMinutes, unit: "min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.temperature"), value: $store.input.waterTemperatureCelsius, unit: "C", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.altitude"), value: $store.input.altitudeMeters, unit: "m", step: 100)
                Divider().overlay(DIRTheme.hairline)
                plannerField("GF Low", value: $store.input.gfLow, unit: "%", step: 5)
                Divider().overlay(DIRTheme.hairline)
                plannerField("GF High", value: $store.input.gfHigh, unit: "%", step: 5)
                Divider().overlay(DIRTheme.hairline)
                HStack {
                    Text(String(localized: "planner.field.salinity"))
                        .font(.callout)
                        .foregroundStyle(.white)
                    Spacer()
                    Picker(String(localized: "planner.field.salinity"), selection: $store.input.salinity) {
                        ForEach(SalinityMode.allCases) { mode in
                            Text(salinityLabel(mode)).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .tint(DIRTheme.cyan)
                }
                .padding(.vertical, 10)
            }
        }
    }

    private var plannerCylindersCard: some View {
        DIRCard(String(localized: "planner.card.cylinders"), icon: "fuelpump", accent: DIRTheme.cyan) {
            VStack(spacing: 12) {
                ForEach($store.input.plannerCylinders) { $entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(String(localized: "planner.cylinder.title"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.muted)
                            Spacer()
                            if store.input.plannerCylinders.count > 1 {
                                Button(role: .destructive) {
                                    store.input.plannerCylinders.removeAll { $0.id == entry.id }
                                    store.input.syncLegacyGasesFromPlannerCylinders()
                                } label: {
                                    Text(String(localized: "planner.cylinder.remove"))
                                        .font(.caption2.weight(.semibold))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        HStack {
                            Text(String(localized: "planner.cylinder.role"))
                                .foregroundStyle(DIRTheme.muted)
                            Spacer()
                            Picker("", selection: $entry.role) {
                                ForEach(GasRole.allCases) { role in
                                    Text(role.localizedTitle).tag(role)
                                }
                            }
                            .labelsHidden()
                            .tint(DIRTheme.cyan)
                        }
                        .font(.callout)
                        HStack {
                            Text(String(localized: "planner.cylinder.tank_size"))
                                .foregroundStyle(DIRTheme.muted)
                            Spacer()
                            Picker("", selection: $entry.tankSize) {
                                ForEach(TankSize.allCases) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                            .labelsHidden()
                            .tint(DIRTheme.cyan)
                        }
                        .font(.callout)
                        Text(
                            String(
                                format: String(localized: "planner.mod.value_format"),
                                Formatters.one(entry.modMeters)
                            )
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        if entry.role != .bottom {
                            plannerField(
                                String(localized: "planner.field.switch_depth"),
                                value: $entry.switchDepthMeters,
                                unit: "m",
                                step: 1
                            )
                        }
                        GasMixCard(
                            title: entry.gas.label,
                            mix: $entry.gas,
                            accent: entry.role == .bottom ? DIRTheme.green : DIRTheme.yellow,
                            showsHelium: entry.role == .bottom
                        )
                        .onChange(of: entry.gas) { _, _ in
                            store.input.syncLegacyGasesFromPlannerCylinders()
                        }
                        if entry.isSwitchDepthBeyondMOD {
                            Text(String(localized: "planner.mod.exceeds_allowed"))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(DIRTheme.red)
                        }
                    }
                    Divider().overlay(DIRTheme.hairline)
                }
                Button {
                    store.input.plannerCylinders.append(
                        PlannerCylinderEntry(
                            role: .deco,
                            tankSize: .liters12,
                            gas: GasMix(name: "Deco", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
                        )
                    )
                } label: {
                    Text(String(localized: "planner.cylinder.add"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                }
                .buttonStyle(.plain)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.sac_rmv"), value: $store.input.sacLitersPerMinute, unit: "L/min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.sac_emergency"), value: $store.input.emergencySacLitersPerMinute, unit: "L/min", step: 1)
            }
        }
        .onChange(of: store.input.plannerCylinders) { _, _ in
            store.input.syncLegacyGasesFromPlannerCylinders()
        }
    }

    private var technicalAnalysisCard: some View {
        DIRCard(String(localized: "planner.card.density_end"), icon: "gauge", accent: DIRTheme.yellow) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "PPO2", value: Formatters.one(store.analysis.ppO2AtDepth), color: warningColor(ppO2: store.analysis.ppO2AtDepth))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.density"), value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: densityColor(store.analysis.densityRating))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "END", value: Formatters.zero(store.analysis.endMeters), unit: "m", color: store.analysis.endMeters > 30 ? DIRTheme.yellow : DIRTheme.green)
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "EAD", value: store.analysis.eadMeters.map { Formatters.zero($0) } ?? "-", unit: store.analysis.eadMeters == nil ? nil : "m", color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "CNS", value: Formatters.zero(store.analysis.cnsPercent), unit: "%", color: store.analysis.cnsPercent > 80 ? DIRTheme.red : DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "OTU", value: Formatters.zero(store.analysis.otu), color: DIRTheme.cyan)
                }
            }
        }
    }

    private var reserveCard: some View {
        DIRCard("GAS RESERVE", icon: "gauge", accent: DIRTheme.green) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: String(localized: "planner.metric.available"), value: Formatters.zero(store.input.availableGasLiters), unit: "L", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.consumption"), value: Formatters.zero(store.analysis.consumptionLiters), unit: "L", color: DIRTheme.yellow)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.remaining"), value: Formatters.zero(store.analysis.remainingBar), unit: "bar", color: store.analysis.remainingLiters < store.analysis.rockBottomLiters ? DIRTheme.red : DIRTheme.green)
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Rock bottom", value: Formatters.zero(store.analysis.minimumGasBar), unit: "bar", color: DIRTheme.orange)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Turn", value: Formatters.zero(store.analysis.turnPressureBar), unit: "bar", color: DIRTheme.cyan)
                }
            }
        }
    }

    private var liveMODIssues: [MODValidationIssue] {
        PlannerMODValidator.validatePlannerCylinders(input: store.input)
    }

    @ViewBuilder
    private var plannerMODInputWarnings: some View {
        if !liveMODIssues.isEmpty {
            DIRCard(String(localized: "planner.mod.validation.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(liveMODIssues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "planner.mod.exceeds_allowed"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.red)
                            Text(
                                String(
                                    format: String(localized: "planner.mod.detail_format"),
                                    issue.gasLabel,
                                    Formatters.one(issue.switchDepthMeters),
                                    Formatters.one(issue.modMeters)
                                )
                            )
                            .font(.caption2)
                            .foregroundStyle(.white)
                        }
                    }
                    Text(String(localized: "planner.mod.incompatible"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
    }

    @ViewBuilder
    private var plannerWarnings: some View {
        if store.analysis.warnings.isEmpty {
            DIRWarningBox(text: String(localized: "planner.disclaimer.informative"))
        } else {
            DIRCard("WARNING", icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(store.analysis.warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(DIRTheme.red)
                                .frame(width: 7, height: 7)
                                .padding(.top, 6)
                            Text(warning)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
    }

    private var teamPreviewCard: some View {
        DIRCard("TEAM GAS MATCHING", icon: "person.2", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                ForEach(store.input.teamMembers) { member in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(member.name)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                            Text("SAC \(Formatters.zero(member.sacLitersPerMinute)) L/min")
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        Spacer()
                        Text("\(Formatters.zero(member.cylinder.availableGasLiters)) L")
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    Divider().overlay(DIRTheme.hairline)
                }
                Text(String(localized: "planner.team.v2_note"))
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var plannerSafetyAcknowledgment: some View {
        Toggle(
            isOn: Binding(
                get: { plannerSafetyAcknowledged },
                set: { plannerSafetyAckRevision = $0 ? PlannerSafetyAcknowledgment.currentRevision : "" }
            )
        ) {
            Text(String(localized: "planner.safety_ack.label"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .tint(DIRTheme.cyan)
        .padding(.vertical, 4)
        .accessibilityHint(String(localized: "planner.safety_ack.hint"))
    }

    private var calculateButton: some View {
        Button {
            store.calculate()
            showPlan = true
        } label: {
            Text(String(localized: "Calcola Piano"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(plannerSafetyAcknowledged ? .black : DIRTheme.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(plannerSafetyAcknowledged ? DIRTheme.cyan : DIRTheme.surface2)
                        .shadow(color: DIRTheme.cyan.opacity(plannerSafetyAcknowledged ? 0.28 : 0), radius: 14, x: 0, y: 8)
                )
        }
        .buttonStyle(.plain)
        .disabled(!plannerSafetyAcknowledged)
        .padding(.top, 4)
        .accessibilityLabel(String(localized: "Calcola Piano"))
        .accessibilityHint(String(localized: "planner.safety_ack.hint"))
    }

    private func plannerField(_ title: String, value: Binding<Double>, unit: String, step: Double) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
            Text("\(Formatters.zero(value.wrappedValue)) \(unit)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 96, alignment: .trailing)
            HStack(spacing: 1) {
                Button {
                    value.wrappedValue = max(0, value.wrappedValue - step)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 24)
                }
                Button {
                    value.wrappedValue += step
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 24)
                }
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(DIRTheme.cyan)
            .background(RoundedRectangle(cornerRadius: 5).fill(DIRTheme.surface2))
        }
        .padding(.vertical, 10)
    }

    private func densityColor(_ rating: GasDensityRating) -> Color {
        switch rating {
        case .green: return DIRTheme.green
        case .yellow: return DIRTheme.yellow
        case .red: return DIRTheme.red
        }
    }

    private func warningColor(ppO2: Double) -> Color {
        ppO2 > store.input.bottomGas.maxPPO2 ? DIRTheme.red : DIRTheme.green
    }
}

struct GasMixCard: View {
    let title: String
    @Binding var mix: GasMix
    let accent: Color
    let showsHelium: Bool

    var body: some View {
        DIRCard(accent: accent) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                }
                HStack {
                    gasMetric(String(localized: "planner.gas.mix_label"), mix.label, alignLeading: true)
                    gasAdjuster("O2", value: mix.oxygen, suffix: "%", step: 0.01) { setOxygen($0) }
                    if showsHelium {
                        gasAdjuster("He", value: mix.helium, suffix: "%", step: 0.01) { setHelium($0) }
                    }
                    gasMetric("N2", "\(Int(mix.nitrogen * 100))%")
                    gasMetric("MOD", "\(Formatters.one(mix.modMeters)) m")
                }
                Divider().overlay(DIRTheme.hairline)
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        gasLine("PPO2 Max", Formatters.one(mix.maxPPO2))
                        gasLine(String(localized: "planner.gas.surface_density"), "\(Formatters.one(mix.surfaceDensityGramsLiter)) g/L")
                    }
                    HStack {
                        Text(String(localized: "planner.gas.adjust_ppo2"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                        Spacer()
                        gasStepper(value: mix.maxPPO2, step: 0.05) { mix.maxPPO2 = min(max($0, 1.0), 1.6) }
                    }
                }
            }
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 3)
                .padding(.vertical, 8)
        }
    }

    private func gasMetric(_ title: String, _ value: String, alignLeading: Bool = false) -> some View {
        VStack(alignment: alignLeading ? .leading : .trailing, spacing: 5) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
            Text(value)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: alignLeading ? .leading : .trailing)
    }

    private func gasLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white)
        }
    }

    private func gasAdjuster(_ title: String, value: Double, suffix: String, step: Double, update: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 3) {
                Button { update(value - step) } label: {
                    Image(systemName: "minus")
                        .font(.caption2.weight(.bold))
                        .frame(width: 18, height: 18)
                }
                Text("\(Int(value * 100))\(suffix)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 42)
                Button { update(value + step) } label: {
                    Image(systemName: "plus")
                        .font(.caption2.weight(.bold))
                        .frame(width: 18, height: 18)
                }
            }
            .foregroundStyle(DIRTheme.cyan)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func gasStepper(value: Double, step: Double, update: @escaping (Double) -> Void) -> some View {
        HStack(spacing: 5) {
            Button { update(value - step) } label: {
                Image(systemName: "minus")
                    .frame(width: 24, height: 22)
            }
            Text(Formatters.one(value))
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 42)
            Button { update(value + step) } label: {
                Image(systemName: "plus")
                    .frame(width: 24, height: 22)
            }
        }
        .foregroundStyle(DIRTheme.cyan)
    }

    private func setOxygen(_ value: Double) {
        let capped = min(max(value, 0.10), 1.0 - mix.helium)
        mix.oxygen = capped
    }

    private func setHelium(_ value: Double) {
        let capped = min(max(value, 0), 1.0 - mix.oxygen)
        mix.helium = capped
    }
}

struct PlanResultView: View {
    @EnvironmentObject private var store: PlannerStore
    @State private var tab: PlanTab = .plan

    private var planShareText: String {
        var lines = [String(localized: "planner.export.header")]
        lines.append("TTR: \(store.plan.ttrMinutes) min")
        lines.append("NDL: \(Formatters.one(store.plan.ndlMinutes)) min")
        lines.append("CNS: \(Formatters.zero(store.plan.cnsPercent))% · OTU: \(Formatters.zero(store.plan.otu))")
        if store.plan.decoStops.isEmpty {
            lines.append(String(localized: "planner.export.no_deco_stops"))
        } else {
            lines.append(String(localized: "planner.export.deco_stops"))
            for stop in store.plan.decoStops {
                lines.append("  \(Formatters.one(stop.depthMeters)) m · \(stop.minutes) min · \(stop.gas) · PPO2 \(Formatters.one(stop.ppO2))")
            }
        }
        lines.append(String(localized: "planner.export.indicative_footer"))
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    resultTabs
                    modValidationSection
                    switch tab {
                    case .plan:
                        resultGrid
                        ascentTable
                        contingencyCard
                        teamMatchCard
                        briefingCard
                    case .curve:
                        buhlmannChart
                    case .charts:
                        segmentTimeline
                        gfComparisonCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .navigationTitle(String(localized: "planner.result.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: planShareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(DIRTheme.cyan)
                }
                .accessibilityLabel(Text(String(localized: "planner.export.share.a11y")))
            }
        }
    }

    @ViewBuilder
    private var modValidationSection: some View {
        if !store.plan.modValidationIssues.isEmpty {
            DIRCard(String(localized: "planner.mod.validation.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(store.plan.modValidationIssues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "planner.mod.exceeds_allowed"))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(DIRTheme.red)
                            Text(
                                String(
                                    format: String(localized: "planner.mod.detail_format"),
                                    issue.gasLabel,
                                    Formatters.one(issue.switchDepthMeters),
                                    Formatters.one(issue.modMeters)
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.white)
                        }
                    }
                    Text(String(localized: "planner.mod.incompatible"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    Text(String(localized: "planner.mod.hint"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
    }

    private var resultTabs: some View {
        HStack(spacing: 0) {
            ForEach(PlanTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 10) {
                        Text(item.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tab == item ? DIRTheme.cyan : .white.opacity(0.72))
                        Rectangle()
                            .fill(tab == item ? DIRTheme.cyan : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 10)
    }

    private var resultGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                    DIRMetricTile(title: "TTR", value: "\(store.plan.ttrMinutes)", unit: "min")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Deco Stops", value: "\(store.plan.decoStops.count)")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "OTU", value: Formatters.zero(store.plan.otu))
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(title: String(localized: "planner.result.max_depth"), value: Formatters.zero(store.input.plannedDepthMeters), unit: "m")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "planner.result.bottom_time"), value: Formatters.zero(store.input.plannedBottomMinutes), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "CNS%", value: Formatters.zero(store.plan.cnsPercent), unit: "%")
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(title: String(localized: "planner.metric.density"), value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: store.analysis.densityRating == .red ? DIRTheme.red : DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "END", value: Formatters.zero(store.analysis.endMeters), unit: "m", color: DIRTheme.yellow)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Turn", value: Formatters.zero(store.analysis.turnPressureBar), unit: "bar", color: DIRTheme.cyan)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private var ascentTable: some View {
        DIRCard(String(localized: "planner.result.ascent_plan"), icon: nil, accent: DIRTheme.cyan) {
            VStack(spacing: 9) {
                tableRow([
                    String(localized: "planner.table.depth"),
                    String(localized: "planner.table.time"),
                    String(localized: "planner.table.gas"),
                    "PPO2"
                ], isHeader: true)
                ForEach(store.plan.decoStops) { stop in
                    tableRow([
                        "\(Formatters.one(stop.depthMeters)) m",
                        "\(stop.minutes) min",
                        stop.gas,
                        Formatters.one(stop.ppO2)
                    ])
                }
                tableRow(["0 m", "-", "SURFACE", "-"])
            }
        }
    }

    private var segmentTimeline: some View {
        DIRCard(String(localized: "planner.result.timeline"), icon: "list.bullet.rectangle", accent: DIRTheme.cyan) {
            VStack(spacing: 8) {
                tableRow([
                    String(localized: "planner.table.type"),
                    String(localized: "planner.table.depth_short"),
                    String(localized: "planner.table.min"),
                    String(localized: "planner.table.gas")
                ], isHeader: true)
                ForEach(store.plan.segments) { segment in
                    tableRow([
                        segment.kind.rawValue,
                        "\(Formatters.zero(segment.depthMeters)) m",
                        Formatters.one(segment.minutes),
                        segment.gas
                    ])
                }
            }
        }
    }

    private var gfComparisonCard: some View {
        DIRCard(String(localized: "planner.result.gf_compare"), icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.green) {
            VStack(spacing: 8) {
                tableRow([
                    "GF",
                    "TTS",
                    String(localized: "planner.table.stops"),
                    String(localized: "planner.table.note")
                ], isHeader: true)
                ForEach(store.plan.gfComparisons) { comparison in
                    tableRow([
                        comparison.label,
                        "\(comparison.ttsMinutes) min",
                        "\(comparison.stopCount)",
                        comparison.conservatismNote
                    ])
                }
            }
        }
    }

    private var contingencyCard: some View {
        DIRCard(String(localized: "planner.result.contingencies"), icon: "exclamationmark.triangle", accent: DIRTheme.yellow) {
            VStack(spacing: 10) {
                ForEach(store.plan.contingencyPlans) { plan in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(plan.scenario.rawValue)
                                .font(.callout.weight(.bold))
                                .foregroundStyle(DIRTheme.yellow)
                            Spacer()
                            Text("\(plan.ttsMinutes) min")
                                .font(.callout.monospacedDigit().weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        Text("\(Formatters.zero(plan.gasRequiredLiters)) L - \(plan.action)")
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Divider().overlay(DIRTheme.hairline)
                }
            }
        }
    }

    private var teamMatchCard: some View {
        DIRCard("TEAM GAS MATCH", icon: "person.2", accent: DIRTheme.cyan) {
            VStack(spacing: 8) {
                tableRow(["Diver", "SAC", "Gas", "Status"], isHeader: true)
                ForEach(store.plan.teamMatches) { match in
                    tableRow([
                        match.diverName,
                        "\(Formatters.zero(match.sacLitersMinute))",
                        "\(Formatters.zero(match.availableLiters)) L",
                        match.status
                    ])
                }
            }
        }
    }

    private var briefingCard: some View {
        DIRCard("BRIEFING", icon: "doc.text", accent: DIRTheme.green) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(store.plan.briefingLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(DIRTheme.cyan)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(line)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.86))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider().overlay(DIRTheme.hairline)
                Text(String(localized: "planner.briefing.share_note"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private func tableRow(_ values: [String], isHeader: Bool = false) -> some View {
        HStack {
            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(isHeader ? .caption2.weight(.semibold) : .caption.monospacedDigit())
                    .foregroundStyle(isHeader ? DIRTheme.muted : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var buhlmannChart: some View {
        DIRCard("CURVA BUHLMANN ZH-L16C", icon: nil, accent: DIRTheme.cyan) {
            Chart(store.buhlmann.curve) { point in
                LineMark(
                    x: .value("Minutes", point.ndlMinutes),
                    y: .value("Load", max(0, 100 - point.depthMeters * 1.5)),
                    series: .value("Compartimenti", point.compartmentGroup)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXAxis {
                AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
            }
            .chartYAxis {
                AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
            }
            .frame(height: 220)
        }
    }
}

enum PlanTab: String, CaseIterable, Identifiable {
    case plan
    case curve
    case charts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plan: return String(localized: "planner.tab.plan")
        case .curve: return String(localized: "planner.tab.curve")
        case .charts: return String(localized: "planner.tab.charts")
        }
    }
}
