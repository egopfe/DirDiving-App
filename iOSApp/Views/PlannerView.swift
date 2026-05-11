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
                        Text("Planner")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        modePicker
                        profileCard
                        gasCards
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
        DIRCard("Profilo Immersione", icon: nil) {
            VStack(spacing: 0) {
                plannerField("Profondita Massima", value: $store.input.plannedDepthMeters, unit: "m", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Tempo al Fondo", value: $store.input.plannedBottomMinutes, unit: "min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField("Temperatura", value: $store.input.waterTemperatureCelsius, unit: "C", step: 1)
            }
        }
    }

    private var gasCards: some View {
        VStack(spacing: 12) {
            GasMixCard(title: "Gas di Fondo", mix: store.input.bottomGas, accent: DIRTheme.green, showsHelium: true)
            GasMixCard(title: "Gas di Decompressione 1", mix: store.input.decoGas1, accent: DIRTheme.yellow, showsHelium: false)
            GasMixCard(title: "Gas di Decompressione 2", mix: store.input.decoGas2, accent: DIRTheme.cyan, showsHelium: false)
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
                .background(RoundedRectangle(cornerRadius: 7).fill(DIRTheme.cyan))
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
                .frame(width: 82, alignment: .trailing)
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
}

struct GasMixCard: View {
    let title: String
    let mix: GasMix
    let accent: Color
    let showsHelium: Bool

    var body: some View {
        DIRCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                }
                HStack {
                    gasMetric("Miscela", mix.label, alignLeading: true)
                    gasMetric("O2", "\(Int(mix.oxygen * 100))%")
                    if showsHelium {
                        gasMetric("He", "\(Int(mix.helium * 100))%")
                    }
                    gasMetric("MOD", "\(Formatters.one(mix.modMeters)) m")
                }
                Divider().overlay(DIRTheme.hairline)
                HStack {
                    Text("PPO2 Max")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    Spacer()
                    Text(Formatters.one(mix.maxPPO2))
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
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
}

struct PlanResultView: View {
    @EnvironmentObject private var store: PlannerStore
    @State private var tab: PlanTab = .plan

    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    resultTabs
                    resultGrid
                    ascentTable
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
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(DIRTheme.cyan)
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
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private var ascentTable: some View {
        DIRCard("PIANO DI RISALITA", icon: nil) {
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
        DIRCard("CURVA BUHLMANN ZH-L16C", icon: nil) {
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
