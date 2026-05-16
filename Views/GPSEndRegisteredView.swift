import SwiftUI

struct GPSEndRegisteredView: View {
    let point: GPSPoint?

    init(point: GPSPoint? = nil) {
        self.point = point
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 25)

                Image(systemName: "checkmark.circle")
                    .font(.system(size: 58, weight: .medium))
                    .foregroundStyle(DiveUI.green)
                    .shadow(color: DiveUI.green.opacity(0.32), radius: 7, x: 0, y: 0)

                Spacer(minLength: 15)

                Text("PUNTO FINE\nREGISTRATO")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.green)
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

                Text("Immersione terminata")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
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

            // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
            Text("--:--")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private var latitudeText: String {
        guard let point else {
            // TODO: Use the captured end GPS latitude when this view receives completed dive context.
            return "41.124210\u{00B0} N"
        }
        return coordinateText(value: point.latitude, positive: "N", negative: "S")
    }

    private var longitudeText: String {
        guard let point else {
            // TODO: Use the captured end GPS longitude when this view receives completed dive context.
            return "16.988210\u{00B0} E"
        }
        return coordinateText(value: point.longitude, positive: "E", negative: "W")
    }

    private func coordinateText(value: Double, positive: String, negative: String) -> String {
        let direction = value >= 0 ? positive : negative
        return String(format: "%.6f\u{00B0} %@", abs(value), direction)
    }
}
