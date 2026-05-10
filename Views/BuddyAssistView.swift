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
            Text("BLE experimental")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
