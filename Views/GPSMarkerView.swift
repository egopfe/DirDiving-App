import SwiftUI

struct GPSMarkerView: View {
    let marker: GPSInterestMarker?

    init(marker: GPSInterestMarker? = nil) {
        self.marker = marker
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 22)

                Image(systemName: "checkmark.circle")
                    .font(.system(size: 58, weight: .medium))
                    .foregroundStyle(DiveUI.green)
                    .shadow(color: DiveUI.green.opacity(0.32), radius: 7, x: 0, y: 0)

                Spacer(minLength: 17)

                Text("MARKER\nSALVATO")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.green)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)

                Spacer(minLength: 12)

                coordinates

                Spacer(minLength: 15)

                categoryCard

                Spacer(minLength: 14)

                Text("Punto GPS salvato")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 10)
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

    private var coordinates: some View {
        VStack(spacing: 5) {
            Text(latitudeText)
            Text(longitudeText)
        }
        .font(.system(size: 13, weight: .regular, design: .rounded))
        .foregroundStyle(.white)
        .monospacedDigit()
    }

    private var categoryCard: some View {
        HStack(spacing: 9) {
            ZStack {
                Circle()
                    .fill(DiveUI.yellow.opacity(0.14))
                Circle()
                    .stroke(DiveUI.yellow.opacity(0.9), lineWidth: 1.4)
                Image(systemName: categorySymbol)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(DiveUI.yellow)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("CATEGORIA")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.secondaryText)
                    .lineLimit(1)
                Text(categoryText)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 57)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.9), lineWidth: 1.3)
                )
                .shadow(color: DiveUI.yellow.opacity(0.14), radius: 5, x: 0, y: 0)
        )
    }

    private var latitudeText: String {
        guard let latitude = marker?.latitude else {
            // TODO: Use the saved marker latitude when this view is wired to the active snorkeling marker.
            return "41.123456\u{00B0} N"
        }
        return coordinateText(value: latitude, positive: "N", negative: "S")
    }

    private var longitudeText: String {
        guard let longitude = marker?.longitude else {
            // TODO: Use the saved marker longitude when this view is wired to the active snorkeling marker.
            return "16.987654\u{00B0} E"
        }
        return coordinateText(value: longitude, positive: "E", negative: "W")
    }

    private var categoryText: String {
        guard let marker else {
            // TODO: Use the active marker category when this view is wired into the snorkeling marker flow.
            return "REEF"
        }
        return marker.category.rawValue
    }

    private var categorySymbol: String {
        marker?.category.symbol ?? "mappin.and.ellipse"
    }

    private func coordinateText(value: Double, positive: String, negative: String) -> String {
        let direction = value >= 0 ? positive : negative
        return String(format: "%.6f\u{00B0} %@", abs(value), direction)
    }
}
