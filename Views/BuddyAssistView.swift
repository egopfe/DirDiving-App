import SwiftUI

struct BuddyAssistView: View {
    @EnvironmentObject private var buddyAssist: BuddyAssistService

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                header
                warning
                proximity

                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(BuddyAssistMessage.allCases) { message in
                        Button(message.title) {
                            buddyAssist.send(message)
                        }
                        .font(.caption2.bold())
                        .buttonStyle(.bordered)
                        .disabled(!buddyAssist.canSend)
                    }
                }

                HStack(spacing: 6) {
                    Button("PAIR") { buddyAssist.startPairing() }
                    Button("STOP") { buddyAssist.stopPairing() }
                }
                .font(.caption2)

                if let last = buddyAssist.events.first {
                    Text("\(last.direction.rawValue.uppercased()) \(last.message.title)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(last.direction == .received ? .green : .cyan)
                }

                if let error = buddyAssist.lastErrorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(8)
        }
        .navigationTitle("BUDDY")
    }

    private var header: some View {
        VStack(spacing: 3) {
            Text("BUDDY ASSIST")
                .font(.headline)
                .foregroundStyle(.cyan)
            Text(buddyAssist.state.rawValue)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(buddyAssist.canSend ? .green : .yellow)
        }
    }

    private var warning: some View {
        Text("Indicazione di prossimità sperimentale non affidabile per sicurezza immersione.")
            .font(.caption2)
            .foregroundStyle(.yellow)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var proximity: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(proximityColor)
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(buddyAssist.proximityState.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(proximityColor)
                Text(pingText)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var proximityColor: Color {
        switch buddyAssist.proximityState {
        case .near: return .green
        case .distant: return .yellow
        case .disconnected: return .red
        }
    }

    private var pingText: String {
        if let lastRSSI = buddyAssist.lastRSSI {
            return "PING 15s RSSI \(lastRSSI)"
        }
        return "PING 15s --"
    }
}
