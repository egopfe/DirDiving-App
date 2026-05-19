import SwiftUI

struct GPSEndRegisteredView: View {
    let point: GPSPoint?
    let isFallback: Bool

    init(point: GPSPoint? = nil, isFallback: Bool = false) {
        self.point = point
        self.isFallback = isFallback
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 25)

                Image(systemName: iconName)
                    .font(.system(size: 58, weight: .medium))
                    .foregroundStyle(stateColor)
                    .shadow(color: stateColor.opacity(0.32), radius: 7, x: 0, y: 0)

                Spacer(minLength: 15)

                Text(titleText)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(stateColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)

                Spacer(minLength: 13)

                VStack(spacing: 5) {
                    Text(latitudeText)
                    Text(longitudeText)
                }
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()

                Spacer(minLength: 20)

                Text(detailText)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 13)
            }
            .padding(.horizontal, 12)
            .padding(.top, 9)
            .padding(.bottom, 8)
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

    private var latitudeText: String {
        guard let point else {
            return "GPS NON DISPONIBILE"
        }
        return coordinateText(value: point.latitude, positive: "N", negative: "S")
    }

    private var longitudeText: String {
        guard let point else {
            return "FIX NON SALVATO"
        }
        return coordinateText(value: point.longitude, positive: "E", negative: "W")
    }

    private var stateColor: Color {
        point == nil || isFallback ? DiveUI.yellow : DiveUI.green
    }

    private var iconName: String {
        point == nil ? "exclamationmark.triangle" : (isFallback ? "location.circle" : "checkmark.circle")
    }

    private var titleText: String {
        guard point != nil else { return "GPS NON DISPONIBILE\nPUNTO NON REGISTRATO" }
        return isFallback ? "ULTIMO PUNTO NOTO\nUTILIZZATO" : "PUNTO FINE\nREGISTRATO"
    }

    private var detailText: String {
        guard point != nil else { return "Immersione terminata senza coordinate GPS valide." }
        return isFallback ? "Fix nuovo non disponibile. Fine salvata con ultimo punto noto." : "Immersione terminata"
    }

    private func coordinateText(value: Double, positive: String, negative: String) -> String {
        let direction = value >= 0 ? positive : negative
        return String(format: "%.6f\u{00B0} %@", abs(value), direction)
    }
}
