import SwiftUI

struct AscentWarningView: View {
    let status: AscentStatus

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 14)

                Text("RISALITA TROPPO VELOCE!")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

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

                Spacer(minLength: 16)

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
}
