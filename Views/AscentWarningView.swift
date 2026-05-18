import SwiftUI

struct AscentWarningView: View {
    let status: AscentStatus
    let depthMeters: Double
    let runtime: TimeInterval

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 8)

                Text("RISALITA TROPPO VELOCE!")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 5)

                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(Formatters.one(status.currentRateMetersPerMinute))
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.red)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .shadow(color: DiveUI.red.opacity(0.38), radius: 7, x: 0, y: 0)
                    Text("m/min")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.red)
                        .padding(.bottom, 12)
                }

                Text("RALLENTA")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.red)
                    .lineLimit(1)

                Spacer(minLength: 8)

                liveContextPanel

                Spacer(minLength: 8)

                Text("Velocità consigliata: ≤ \(Formatters.one(status.limitMetersPerMinute)) m/min")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 9)

                chevrons

                Spacer(minLength: 5)
            }
            .padding(.horizontal, 12)
            .padding(.top, 9)
            .padding(.bottom, 7)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            DiveClockText(size: 14)
        }
    }

    private var chevrons: some View {
        VStack(spacing: -8) {
            ForEach(0..<3, id: \.self) { _ in
                Image(systemName: "chevron.down")
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(DiveUI.red)
            }
        }
        .shadow(color: DiveUI.red.opacity(0.28), radius: 5, x: 0, y: 0)
    }

    private var liveContextPanel: some View {
        HStack(spacing: 0) {
            warningMetric(title: "Depth", value: Formatters.one(depthMeters), unit: "m", color: .white)
            Rectangle().fill(.white.opacity(0.24)).frame(width: 1, height: 36)
            warningMetric(title: "RunTime", value: runtimeMinutes, unit: "min", color: DiveUI.yellow)
        }
        .frame(maxWidth: .infinity, minHeight: 46)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.50))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(DiveUI.red.opacity(0.70), lineWidth: 1.2))
        )
    }

    private func warningMetric(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text(unit)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var runtimeMinutes: String {
        Formatters.zero(runtime / 60)
    }
}
