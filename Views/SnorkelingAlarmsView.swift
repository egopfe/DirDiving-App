import SwiftUI

struct SnorkelingAlarmsView: View {
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 12) {
                header

                Spacer(minLength: 8)

                Text("ALLARMI SNORKELING")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, alignment: .center)

                alarmsPanel

                Spacer(minLength: 10)

                backButton
            }
            .padding(.horizontal, 11)
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
                    // TODO: Replace this visual placeholder when snorkeling exposes water temperature in this view.
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

    private var alarmsPanel: some View {
        VStack(spacing: 0) {
            alarmRow(title: "Profondità massima", value: "10.0 m")
            alarmDivider
            alarmRow(title: "Tempo massimo", value: "60 min")
            alarmDivider
            alarmRow(title: "Distanza massima", value: "5.0 km")
            alarmDivider
            alarmRow(title: "Batteria bassa", value: "20 %")
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.white.opacity(0.28), lineWidth: 1.2)
                )
        )
    }

    private func alarmRow(title: String, value: String) -> some View {
        // TODO: Wire values to snorkeling-specific alarm settings when those settings exist.
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.horizontal, 11)
        .frame(height: 45)
        .contentShape(Rectangle())
    }

    private var alarmDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.16))
            .frame(height: 1)
    }

    private var backButton: some View {
        Button {
            onBack?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .black))
                Text("INDIETRO")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(DiveUI.blue)
            .frame(maxWidth: .infinity, minHeight: 45)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.black.opacity(0.36))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(DiveUI.blue.opacity(0.75), lineWidth: 1.3)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
