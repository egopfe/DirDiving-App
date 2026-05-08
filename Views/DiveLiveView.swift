import SwiftUI

struct DiveLiveView: View {
    @EnvironmentObject private var dive: DiveManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 6) {
                HStack {
                    Text("DIR DIVING").font(.caption2.bold()).foregroundStyle(.cyan)
                    Spacer()
                    if let temp = dive.currentTemperatureCelsius {
                        Text("\(Formatters.one(temp))°C").font(.caption2.monospacedDigit()).foregroundStyle(.cyan)
                    }
                }

                HStack(alignment: .top, spacing: 8) {
                    AscentGaugeView(status: dive.ascentStatus).frame(width: 56, height: 122)
                    VStack(spacing: 2) {
                        Text("TTV").font(.caption2).foregroundStyle(.secondary)
                        Text(Formatters.one(dive.ttv)).font(.title3.bold()).foregroundStyle(.white)
                        Text("\(Formatters.one(dive.currentDepthMeters)) m")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(dive.redWarningBlink ? .red : .white)
                        Text("MAX \(Formatters.one(dive.maxDepthMeters))  AVG \(Formatters.one(dive.averageDepthMeters))")
                            .font(.caption2).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity)
                }

                Text("RunTime").font(.caption2).foregroundStyle(.secondary)
                Text(Formatters.time(dive.runtime)).font(.title3.monospacedDigit().bold()).foregroundStyle(.yellow)

                HStack(spacing: 5) {
                    Button("START") { dive.startStopwatch() }.font(.caption2)
                    Button("STOP") { dive.stopStopwatch() }.font(.caption2)
                    Button("RESET") { dive.resetStopwatch() }.font(.caption2)
                }
                Text("CHR \(Formatters.time(dive.stopwatchTime))").font(.caption2.monospacedDigit()).foregroundStyle(.orange)

                if let error = dive.lastErrorMessage {
                    Text(error).font(.caption2).foregroundStyle(.yellow).multilineTextAlignment(.center)
                }
            }.padding(8)
        }
    }
}
