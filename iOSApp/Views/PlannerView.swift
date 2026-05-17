import SwiftUI
import Charts

struct PlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    @State private var showPlan = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 13) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Planner")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        modePicker
                        plannerSafetyNotice
                        profileCard
                        gasCards
                        calculateButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 22)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Modalita")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            HStack(spacing: 0) {
                ForEach(PlannerMode.allCases) { mode in
                    Button {
                        store.mode = mode
                    } label: {
                        Text(mode.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(store.mode == mode ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(store.mode == mode ? DIRTheme.cyan : .clear)
                                    .shadow(color: store.mode == mode ? DIRTheme.cyan.opacity(0.38) : .clear, radius: 5, x: 0, y: 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color(red: 0.055, green: 0.070, blue: 0.095))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.white.opacity(0.045), lineWidth: 1)
                    )
            )
        }
    }

    private var plannerSafetyNotice: some View {
        Text("Planner informativo non certificato. Non usare per eseguire immersioni reali senza strumenti validati, tabelle/agenzia e pianificazione conservativa.")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(DIRTheme.yellow)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(DIRTheme.yellow.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(DIRTheme.yellow.opacity(0.42), lineWidth: 1))
            )
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Profilo Immersione")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            VStack(spacing: 0) {
                plannerField("Profondita Massima", value: $store.input.plannedDepthMeters, unit: "m", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Tempo al Fondo", value: $store.input.plannedBottomMinutes, unit: "min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Temperatura", value: $store.input.waterTemperatureCelsius, unit: "C", step: 1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }

    private var gasCards: some View {
        VStack(spacing: 12) {
            GasMixCard(title: "Gas di Fondo", mix: $store.input.bottomGas, accent: DIRTheme.green, showsHelium: true)
            GasMixCard(title: "Gas di Decompressione 1", mix: $store.input.decoGas1, accent: DIRTheme.yellow, showsHelium: false)
            GasMixCard(title: "Gas di Decompressione 2", mix: $store.input.decoGas2, accent: DIRTheme.cyan, showsHelium: false)
        }
    }

    private var calculateButton: some View {
        Button {
            store.calculate()
            showPlan = true
        } label: {
            Text("Calcola Piano")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(DIRTheme.cyan)
                        .shadow(color: DIRTheme.cyan.opacity(0.34), radius: 10, x: 0, y: 6)
                )
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private func plannerField(_ title: String, value: Binding<Double>, unit: String, step: Double) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Text("\(Formatters.zero(value.wrappedValue)) \(unit)")
                .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 72, alignment: .trailing)
            HStack(spacing: 0) {
                Button {
                    value.wrappedValue = max(0, value.wrappedValue - step)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 24, height: 22)
                }
                Button {
                    value.wrappedValue += step
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 24, height: 22)
                }
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(DIRTheme.cyan)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color(red: 0.045, green: 0.060, blue: 0.080))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(DIRTheme.cyan.opacity(0.18), lineWidth: 1)
                    )
            )
        }
        .padding(.vertical, 8)
    }
}

struct GasMixCard: View {
    let title: String
    @Binding var mix: GasMix
    let accent: Color
    let showsHelium: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            HStack {
                gasMetric("Miscela", mix.label, alignLeading: true)
                gasAdjuster("O2", value: mix.oxygen, suffix: "%", step: 0.01) { setOxygen($0) }
                if showsHelium {
                    gasAdjuster("He", value: mix.helium, suffix: "%", step: 0.01) { setHelium($0) }
                }
                gasMetric("MOD", "\(Formatters.one(mix.modMeters)) m")
            }
            Divider().overlay(DIRTheme.hairline)
            HStack {
                Text("PPO2 Max")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                gasStepper(value: mix.maxPPO2, step: 0.05) { mix.maxPPO2 = min(max($0, 1.0), 1.6) }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(accent.opacity(0.42), lineWidth: 1)
                )
        )
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
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: alignLeading ? .leading : .trailing)
    }

    private func gasAdjuster(_ title: String, value: Double, suffix: String, step: Double, update: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 3) {
                Button { update(value - step) } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 8, weight: .bold))
                        .frame(width: 18, height: 18)
                }
                Text("\(Int(value * 100))\(suffix)")
                    .font(.system(size: 11, weight: .medium, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 42)
                Button { update(value + step) } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .bold))
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
                .font(.system(size: 12, weight: .medium, design: .rounded).monospacedDigit())
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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    resultTabs
                    switch tab {
                    case .plan:
                        plannerSafetyNotice
                        modelNotice
                        resultGrid
                        ascentTable
                    case .curve:
                        modelNotice
                        buhlmannChart
                    case .charts:
                        modelNotice
                        resultGrid
                        buhlmannChart
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 22)
            }
        }
        .navigationTitle("Piano Immersione")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultTabs: some View {
        HStack(spacing: 0) {
            ForEach(PlanTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 8) {
                        Text(item.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
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
        .padding(.top, 2)
    }

    private var plannerSafetyNotice: some View {
        Text("MODELLO SEMPLIFICATO: valori indicativi per revisione e studio. Non e un piano decompressivo certificato.")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(DIRTheme.yellow)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .modifier(ResultPanelStyle(cornerRadius: 9))
    }

    private var modelNotice: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Valori indicativi calcolati dagli input correnti: \(Formatters.zero(store.input.plannedDepthMeters)) m / \(Formatters.zero(store.input.plannedBottomMinutes)) min / \(store.input.bottomGas.label).")
            if let warning = store.buhlmann.warning {
                Text(warning)
            }
        }
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .foregroundStyle(DIRTheme.yellow)
        .fixedSize(horizontal: false, vertical: true)
        .padding(10)
        .modifier(ResultPanelStyle(cornerRadius: 9))
    }

    private var resultGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                resultMetric("TTR", value: "\(store.plan.ttrMinutes)", unit: "min")
                Divider().overlay(DIRTheme.hairline)
                resultMetric("Deco Stops", value: "\(store.plan.decoStops.count)")
                Divider().overlay(DIRTheme.hairline)
                resultMetric("OTU", value: Formatters.zero(store.plan.otu))
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                resultMetric("Prof. Max", value: Formatters.zero(store.input.plannedDepthMeters), unit: "m")
                Divider().overlay(DIRTheme.hairline)
                resultMetric("Tempo Fondo", value: Formatters.zero(store.input.plannedBottomMinutes), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                resultMetric("CNS%", value: Formatters.zero(store.plan.cnsPercent), unit: "%")
            }
        }
        .padding(.vertical, 2)
        .modifier(ResultPanelStyle(cornerRadius: 9))
    }

    private var ascentTable: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PIANO DI RISALITA")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DIRTheme.cyan)
            VStack(spacing: 9) {
                tableRow(["Profondita", "Tempo", "Gas", "PPO2"], isHeader: true)
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
        .padding(12)
        .modifier(ResultPanelStyle(cornerRadius: 9))
    }

    private func resultMetric(_ title: String, value: String, unit: String? = nil) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(DIRTheme.muted)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                if let unit = unit {
                    Text(unit)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 56)
        .padding(.horizontal, 4)
    }

    private func tableRow(_ values: [String], isHeader: Bool = false) -> some View {
        HStack {
            ForEach(values, id: \.self) { value in
                Text(value)
                    .font(
                        isHeader
                            ? .system(size: 10, weight: .semibold, design: .rounded)
                            : .system(size: 10, weight: .medium, design: .rounded).monospacedDigit()
                    )
                    .foregroundStyle(isHeader ? DIRTheme.muted : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var buhlmannChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CURVA BUHLMANN ZH-L16C")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DIRTheme.cyan)
            Chart(store.buhlmann.curve) { point in
                LineMark(
                    x: .value("Minutes", point.ndlMinutes),
                    y: .value("Load", max(0, 100 - point.depthMeters * 1.5)),
                    series: .value("Compartimenti", point.compartmentGroup)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.black.opacity(0.18))
                    .overlay(
                        Rectangle()
                            .stroke(DIRTheme.cyan.opacity(0.12), lineWidth: 1)
                    )
            }
            .chartXAxis {
                AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
            }
            .chartYAxis {
                AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
            }
            .frame(height: 190)
        }
        .padding(12)
        .modifier(ResultPanelStyle(cornerRadius: 9))
    }
}

private struct ResultPanelStyle: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(red: 0.020, green: 0.035, blue: 0.048).opacity(0.94))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
            )
        }
    }

enum PlanTab: String, CaseIterable, Identifiable {
    case plan = "PIANO"
    case curve = "CURVA BUHLMANN"
    case charts = "GRAFICI"
    var id: String { rawValue }
}
