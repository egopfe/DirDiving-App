import SwiftUI

struct InfoView: View {
    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 5) {
                header

                Text("INFO")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    infoRow(title: "Versione", value: "1.0.0")
                    deviceRow
                    batteryRow
                    infoRow(title: "Spazio libero", value: "1.2 GB")
                }
            }
            .padding(.horizontal, 11)
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

    private func infoRow(title: String, value: String) -> some View {
        // TODO: Wire to real app/device info when those values are exposed to the watch UI.
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(minHeight: 34)
        .background(rowBackground)
    }

    private var deviceRow: some View {
        // TODO: Replace with the actual paired/watch device name if it becomes available to this view.
        VStack(alignment: .leading, spacing: 2) {
            Text("Dispositivo")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text("Apple Watch Ultra")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(rowBackground)
    }

    private var batteryRow: some View {
        // TODO: Replace placeholder percentage with the actual watch battery level when exposed.
        VStack(spacing: 5) {
            HStack {
                Text("Batteria")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text("78%")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.22))
                    Capsule()
                        .fill(DiveUI.green)
                        .frame(width: geometry.size.width * 0.78)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(minHeight: 42)
        .background(rowBackground)
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(Color.black.opacity(0.52))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            )
    }
}
