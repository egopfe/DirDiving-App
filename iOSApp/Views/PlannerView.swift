import SwiftUI
import Charts

struct PlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        DIRSectionHeader(title: "Planner", subtitle: "Gas, MOD, TTR and Bühlmann assistant")
                        Picker("Modalità", selection: $store.mode) {
                            ForEach(PlannerMode.allCases) { Text($0.rawValue).tag($0) }
                        }.pickerStyle(.segmented)
                        profileCard
                        gasCards
                        resultCard
                        ascentPlanCard
                        buhlmannCard
                        DIRWarningBox(text: "Uso informativo: non sostituisce computer subacqueo, tabelle certificate, training o procedure del team.")
                    }.padding()
                }
            }.navigationTitle("Planner").navigationBarTitleDisplayMode(.inline)
        }
    }
    private var profileCard: some View {
        DIRCard("Profilo immersione", icon: "point.topleft.down.curvedto.point.bottomright.up") {
            VStack(spacing: 12) {
                field("Profondità massima", value: $store.input.plannedDepthMeters, unit: "m")
                field("Tempo al fondo", value: $store.input.plannedBottomMinutes, unit: "min")
                field("Temperatura", value: $store.input.waterTemperatureCelsius, unit: "°C")
                Button("Calcola Piano") { store.calculate() }.buttonStyle(.borderedProminent).tint(DIRTheme.cyan)
            }
        }
    }
    private var gasCards: some View {
        VStack(spacing: 12) {
            GasMixCard(title: "Gas di Fondo", mix: store.input.bottomGas, accent: DIRTheme.green)
            GasMixCard(title: "Gas di Decompressione 1", mix: store.input.decoGas1, accent: DIRTheme.yellow)
            GasMixCard(title: "Gas di Decompressione 2", mix: store.input.decoGas2, accent: DIRTheme.cyan)
        }
    }
    private var resultCard: some View {
        DIRCard("Risultato piano", icon: "square.grid.2x2") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                DIRMetricTile(title: "TTR", value: "\(store.plan.ttrMinutes)", unit: "min")
                DIRMetricTile(title: "Deco Stops", value: "\(store.plan.decoStops.count)", color: DIRTheme.yellow)
                DIRMetricTile(title: "OTU", value: Formatters.zero(store.plan.otu))
                DIRMetricTile(title: "Prof. Max", value: Formatters.one(store.input.plannedDepthMeters), unit: "m", color: DIRTheme.cyan)
                DIRMetricTile(title: "Tempo fondo", value: Formatters.zero(store.input.plannedBottomMinutes), unit: "min")
                DIRMetricTile(title: "CNS", value: Formatters.zero(store.plan.cnsPercent), unit: "%", color: store.plan.cnsPercent > 80 ? DIRTheme.red : DIRTheme.green)
            }
        }
    }
    private var ascentPlanCard: some View {
        DIRCard("Piano di risalita", icon: "arrow.up.forward") {
            VStack(spacing: 8) {
                HStack { Text("Profondità"); Spacer(); Text("Tempo"); Spacer(); Text("Gas"); Spacer(); Text("PPO₂") }.font(.caption.bold()).foregroundStyle(DIRTheme.muted)
                ForEach(store.plan.decoStops) { stop in
                    HStack {
                        Text("\(Formatters.one(stop.depthMeters)) m"); Spacer()
                        Text("\(stop.minutes) min"); Spacer()
                        Text(stop.gas); Spacer()
                        Text(Formatters.one(stop.ppO2))
                    }.font(.callout.monospacedDigit())
                    Divider().background(DIRTheme.faint)
                }
            }
        }
    }
    private var buhlmannCard: some View {
        DIRCard("Curva Bühlmann ZHL-16C", icon: "chart.xyaxis.line") {
            Chart(store.buhlmann.curve) { point in
                LineMark(x: .value("Depth", point.depthMeters), y: .value("NDL", point.ndlMinutes), series: .value("Compartimenti", point.compartmentGroup)).lineStyle(StrokeStyle(lineWidth: 2))
            }.frame(height: 240)
        }
    }
    private func field(_ title: String, value: Binding<Double>, unit: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            TextField(title, value: value, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing).font(.body.monospacedDigit()).frame(width: 90)
            Text(unit).foregroundStyle(DIRTheme.muted)
        }.padding(10).background(RoundedRectangle(cornerRadius: 14).fill(DIRTheme.surface2.opacity(0.72)))
    }
}
struct GasMixCard: View {
    let title: String
    let mix: GasMix
    let accent: Color
    var body: some View {
        DIRCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    RoundedRectangle(cornerRadius: 2).fill(accent).frame(width: 4)
                    Text(title).font(.headline).foregroundStyle(.white)
                    Spacer()
                    Text(mix.label).foregroundStyle(accent).bold()
                }
                HStack {
                    metric("O₂", "\(Int(mix.oxygen * 100))%")
                    metric("He", "\(Int(mix.helium * 100))%")
                    metric("MOD", "\(Formatters.one(mix.modMeters)) m")
                    metric("PPO₂", Formatters.one(mix.maxPPO2))
                }
            }
        }
    }
    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption2).foregroundStyle(DIRTheme.muted)
            Text(value).font(.callout.monospacedDigit()).foregroundStyle(.white)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
