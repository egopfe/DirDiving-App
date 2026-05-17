import SwiftUI
import Charts

struct PlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    @State private var showPlan = false

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Planner")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Gas, deco profile and Buhlmann presentation with high-contrast technical cards")
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        modePicker
                        profileCard
                        gasCards
                        cylinderCard
                        technicalAnalysisCard
                        reserveCard
                        teamPreviewCard
                        plannerWarnings
                        calculateButton
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
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(PlannerMode.allCases) { mode in
                Button {
                    store.mode = mode
                } label: {
                    Text(mode.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(store.mode == mode ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(store.mode == mode ? DIRTheme.cyan : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.82)))
    }

    private var profileCard: some View {
        DIRCard("Profilo Immersione", icon: nil, accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                plannerField("Profondita Massima", value: $store.input.plannedDepthMeters, unit: "m", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Tempo al Fondo", value: $store.input.plannedBottomMinutes, unit: "min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Temperatura", value: $store.input.waterTemperatureCelsius, unit: "C", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Quota", value: $store.input.altitudeMeters, unit: "m", step: 100)
                Divider().overlay(DIRTheme.hairline)
                plannerField("GF Low", value: $store.input.gfLow, unit: "%", step: 5)
                Divider().overlay(DIRTheme.hairline)
                plannerField("GF High", value: $store.input.gfHigh, unit: "%", step: 5)
                Divider().overlay(DIRTheme.hairline)
                HStack {
                    Text("Salinita")
                        .font(.callout)
                        .foregroundStyle(.white)
                    Spacer()
                    Picker("Salinita", selection: $store.input.salinity) {
                        ForEach(SalinityMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .tint(DIRTheme.cyan)
                }
                .padding(.vertical, 10)
            }
        }
    }

    private var gasCards: some View {
        VStack(spacing: 12) {
            GasMixCard(title: "Gas di Fondo", mix: $store.input.bottomGas, accent: DIRTheme.green, showsHelium: true)
            GasMixCard(title: "Gas di Decompressione 1", mix: $store.input.decoGas1, accent: DIRTheme.yellow, showsHelium: false)
            GasMixCard(title: "Gas di Decompressione 2", mix: $store.input.decoGas2, accent: DIRTheme.cyan, showsHelium: false)
        }
    }

    private var cylinderCard: some View {
        DIRCard("BOMBOLA E CONSUMO", icon: "fuelpump", accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                plannerField("Volume", value: $store.input.cylinder.volumeLiters, unit: "L", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Pressione iniziale", value: $store.input.cylinder.startPressure, unit: store.input.cylinder.pressureUnit.rawValue, step: 10)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Riserva", value: $store.input.cylinder.reservePressure, unit: store.input.cylinder.pressureUnit.rawValue, step: 5)
                Divider().overlay(DIRTheme.hairline)
                HStack {
                    Text("Unita pressione")
                        .font(.callout)
                        .foregroundStyle(.white)
                    Spacer()
                    Picker("Unita pressione", selection: $store.input.cylinder.pressureUnit) {
                        ForEach(PressureUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .labelsHidden()
                    .tint(DIRTheme.cyan)
                }
                .padding(.vertical, 10)
                Divider().overlay(DIRTheme.hairline)
                plannerField("SAC/RMV", value: $store.input.sacLitersPerMinute, unit: "L/min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("SAC emergenza", value: $store.input.emergencySacLitersPerMinute, unit: "L/min", step: 1)
            }
        }
    }

    private var technicalAnalysisCard: some View {
        DIRCard("DENSITA / END", icon: "gauge", accent: DIRTheme.yellow) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "PPO2", value: Formatters.one(store.analysis.ppO2AtDepth), color: warningColor(ppO2: store.analysis.ppO2AtDepth))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Densita", value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: densityColor(store.analysis.densityRating))
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
                    DIRMetricTile(title: "Disponibile", value: Formatters.zero(store.input.availableGasLiters), unit: "L", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Consumo", value: Formatters.zero(store.analysis.consumptionLiters), unit: "L", color: DIRTheme.yellow)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Residuo", value: Formatters.zero(store.analysis.remainingBar), unit: "bar", color: store.analysis.remainingLiters < store.analysis.rockBottomLiters ? DIRTheme.red : DIRTheme.green)
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

    @ViewBuilder
    private var plannerWarnings: some View {
        if store.analysis.warnings.isEmpty {
            DIRWarningBox(text: "Planner informativo: verifica sempre piano, gas e procedure con training, team e strumenti certificati.")
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
                Text("V2: confronto team basato su gas disponibile, minimum gas e riserva.")
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var calculateButton: some View {
        Button {
            store.calculate()
            showPlan = true
        } label: {
            Text("Calcola Piano")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.cyan).shadow(color: DIRTheme.cyan.opacity(0.28), radius: 14, x: 0, y: 8))
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
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
                    gasMetric("Miscela", mix.label, alignLeading: true)
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
                        gasLine("Densita superficie", "\(Formatters.one(mix.surfaceDensityGramsLiter)) g/L")
                    }
                    HStack {
                        Text("Regola PPO2")
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
    @State private var exportNotice: String?

    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    DIRWarningBox(text: "PIANO LAB: calcoli semplificati per revisione UI. Non usare come piano operativo o safety-critical.")
                    if let exportNotice {
                        Text(exportNotice)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.yellow)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    resultTabs
                    resultGrid
                    ascentTable
                    segmentTimeline
                    gfComparisonCard
                    contingencyCard
                    teamMatchCard
                    briefingCard
                    buhlmannChart
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .navigationTitle("Piano Immersione")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    exportNotice = "Export piano LAB non generato: serve motore planner validato e formato export approvato."
                } label: {
                    Text("EXPORT LAB")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(DIRTheme.yellow)
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
                        Text(item.rawValue)
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
                DIRMetricTile(title: "Prof. Max", value: Formatters.zero(store.input.plannedDepthMeters), unit: "m")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "Tempo Fondo", value: Formatters.zero(store.input.plannedBottomMinutes), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: "CNS%", value: Formatters.zero(store.plan.cnsPercent), unit: "%")
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(title: "Densita", value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: store.analysis.densityRating == .red ? DIRTheme.red : DIRTheme.cyan)
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
        DIRCard("PIANO DI RISALITA", icon: nil, accent: DIRTheme.cyan) {
            VStack(spacing: 9) {
                tableRow(["Profondita", "Tempo", "Gas", "PPO2"], isHeader: true)
                tableRow(["40.0 m", "20 min", "TRIMIX 18/45", "1.30"])
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
        DIRCard("TIMELINE MULTI-SEGMENTO", icon: "list.bullet.rectangle", accent: DIRTheme.cyan) {
            VStack(spacing: 8) {
                tableRow(["Tipo", "Prof.", "Min", "Gas"], isHeader: true)
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
        DIRCard("COMPARAZIONE GF", icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.green) {
            VStack(spacing: 8) {
                tableRow(["GF", "TTS", "Stops", "Nota"], isHeader: true)
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
        DIRCard("CONTINGENZE", icon: "exclamationmark.triangle", accent: DIRTheme.yellow) {
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
                Text("PDF-ready: contenuto pronto per export briefing nella fase di condivisione iOS.")
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
    case plan = "PIANO"
    case curve = "CURVA BUHLMANN"
    case charts = "GRAFICI"
    var id: String { rawValue }
}
