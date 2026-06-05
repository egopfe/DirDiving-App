import SwiftUI

struct SnorkelingMarkerDetailView: View {
    let marker: GPSInterestMarker?
    let title: String
    var onBack: (() -> Void)?
    var onDelete: (() -> Void)?

    init(
        marker: GPSInterestMarker? = nil,
        title: String = "POI 3",
        onBack: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.marker = marker
        self.title = title
        self.onBack = onBack
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 0) {
                header

                statusRow

                Text("DETTAGLIO MARCATORE")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 11)

                markerHero
                    .padding(.top, 20)

                Spacer(minLength: 20)

                VStack(spacing: 10) {
                    detailRow(title: "Distanza da te", value: distanceText, color: DiveUI.yellow)
                    detailRow(title: "Direzione", value: bearingText, color: DiveUI.yellow)
                    detailRow(title: "Profondità", value: depthText, color: DiveUI.yellow)
                    detailRow(title: "Foto/Note", value: "Companion iOS", color: DiveUI.green)
                }

                Spacer(minLength: 18)

                deleteButton

                Spacer(minLength: 12)

                backButton
            }
            .padding(.horizontal, 12)
            .padding(.top, 9)
            .padding(.bottom, 8)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            HStack(spacing: 7) {
                Image(systemName: "figure.pool.swim")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(width: 29, height: 28)
                Text("SNORKELING")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 13, weight: .bold))
                    // TODO: Replace this visual placeholder if marker temperature is added to the lightweight POI payload.
                    Text("19.6 \u{00B0}C")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundStyle(DiveUI.blue)

                // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
                Text("--:--")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "water.waves")
                .font(.system(size: 16, weight: .black))
            Text("MARCATORI")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.green)
        .padding(.top, 16)
    }

    private var markerHero: some View {
        HStack(spacing: 18) {
            Image(systemName: "mappin")
                .font(.system(size: 82, weight: .black))
                .foregroundStyle(DiveUI.yellow)
                .frame(width: 88, height: 100)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
                Text("\(timeText) • Da arricchire su iPhone")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Spacer(minLength: 0)
        }
    }

    private func detailRow(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 46)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(.white.opacity(0.28), lineWidth: 1)
                )
        )
    }

    private var deleteButton: some View {
        Button {
            onDelete?()
        } label: {
            Text("ELIMINA MARCATORE")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.red)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, minHeight: 45)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.black.opacity(0.36))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(DiveUI.red.opacity(0.92), lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var backButton: some View {
        Button {
            onBack?()
        } label: {
            VStack(spacing: 2) {
                Text("INDIETRO")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                Image(systemName: "arrow.left")
                    .font(.system(size: 27, weight: .black))
            }
            .foregroundStyle(DiveUI.cyan)
            .frame(width: 118, height: 55)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(DiveUI.cyan.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(DiveUI.cyan.opacity(0.9), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var timeText: String {
        guard let marker else {
            // TODO: Use the POI timestamp once this detail is opened from a selected marker.
            return "09:38"
        }
        return Self.timeFormatter.string(from: marker.timestamp)
    }

    private var distanceText: String {
        guard let marker else {
            // TODO: Use marker.distanceFromEntryMeters or live distance from current user position when wired.
            return "730 m"
        }
        return "\(Int(marker.distanceFromEntryMeters.rounded())) m"
    }

    private var bearingText: String {
        guard let marker else {
            // TODO: Use marker bearing when this detail is opened from a selected marker.
            return "214\u{00B0} SW"
        }
        return "\(Int(marker.bearingDegrees.rounded()))\u{00B0} \(cardinal(for: marker.bearingDegrees))"
    }

    private var depthText: String {
        guard let marker else {
            // TODO: Use the captured shallow POI depth when available.
            return "2.3 m"
        }
        return "\(Formatters.one(marker.depthMeters)) m"
    }

    private func cardinal(for bearing: Double) -> String {
        let normalized = (bearing.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        switch normalized {
        case 337.5..<360, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        default: return "NW"
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
