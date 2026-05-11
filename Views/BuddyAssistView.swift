import SwiftUI

struct BuddyAssistView: View {
    @EnvironmentObject private var buddyAssist: BuddyAssistService
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager
    @State private var isAnswering = false

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                header
                warning
                pairingPanel
                buddyLink
                proximity
                compassBlock
                receivedBanner

                messageGrid(title: isAnswering ? "ANSWER" : "SEND")

                HStack(spacing: 6) {
                    Button("PAIR") { buddyAssist.startPairing(isDiveActive: dive.isDiveActive) }
                        .disabled(dive.isDiveActive)
                    Button("STOP") { buddyAssist.stopPairing() }
                    Button("UNPAIR") { buddyAssist.forgetBuddy() }
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
        .onAppear {
            compass.start()
            buddyAssist.updateCompassContext(headingDegrees: compass.headingDegrees, bearingDegrees: compass.bearingDegrees)
        }
        .onDisappear {
            compass.stop()
        }
        .onReceive(compass.$headingDegrees) { heading in
            buddyAssist.updateCompassContext(headingDegrees: heading, bearingDegrees: compass.bearingDegrees)
        }
        .onReceive(compass.$bearingDegrees) { bearing in
            buddyAssist.updateCompassContext(headingDegrees: compass.headingDegrees, bearingDegrees: bearing)
        }
        .onReceive(dive.$isDiveActive) { isDiveActive in
            if isDiveActive {
                buddyAssist.cancelPairingForActiveDive()
            }
        }
    }

    @ViewBuilder
    private var receivedBanner: some View {
        if let event = buddyAssist.activeReceivedMessage {
            VStack(spacing: 6) {
                Text("MESSAGGIO BUDDY")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                Text(event.message.title)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                HStack(spacing: 6) {
                    Button("ANSWER") {
                        isAnswering = true
                    }
                    Button("OK") {
                        isAnswering = false
                        buddyAssist.clearActiveReceivedMessage()
                    }
                }
                .font(.caption2.bold())
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(event.message.isCritical ? .red.opacity(0.65) : .green.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
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
        VStack(spacing: 4) {
            Text("Indicazione di prossimit\u{00E0} sperimentale non affidabile per sicurezza immersione.")
            Text("Pairing solo prima dell'immersione. Non effettuare pairing in immersione.")
        }
        .font(.caption2)
        .foregroundStyle(.yellow)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var pairingPanel: some View {
        VStack(spacing: 5) {
            HStack {
                Text("PAIRING PRE-DIVE")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
                Spacer()
                Text(buddyAssist.pairingStatusText)
                    .font(.caption2.monospacedDigit().bold())
                    .foregroundStyle(buddyAssist.isPaired ? .green : .red)
            }

            HStack {
                Text("Buddy")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.78))
                Spacer()
                Text(buddyAssist.isPaired ? buddyAssist.pairedBuddyDisplayName : "--")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if dive.isDiveActive {
                Text("PAIRING BLOCCATO: IMMERSIONE ATTIVA")
                    .font(.caption2.bold())
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(dive.isDiveActive ? .red : .green, lineWidth: 1)
        )
    }

    private var buddyLink: some View {
        HStack {
            Text("Buddy Link")
                .font(.caption.bold())
                .foregroundStyle(.white)
            Spacer()
            Text(buddyAssist.buddyLinkStatus)
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(buddyAssist.isBuddyOnline ? .green : .red)
        }
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

    private var compassBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("BUSSOLA")
                .font(.caption.bold())
                .foregroundStyle(.cyan)
            compassRow("Ultima direzione", degrees: buddyAssist.lastKnownDirectionDegrees)
            compassRow("Bearing condiviso", degrees: buddyAssist.sharedBearingDegrees)
            compassRow("Heading", degrees: compass.headingDegrees)
            HStack {
                Text("Direzione plausibile")
                Spacer()
                Text(directionText(buddyAssist.plausibleDirectionDegrees))
                    .foregroundStyle(.yellow)
                    .monospacedDigit()
            }
            .font(.caption2.bold())
        }
        .padding(.vertical, 4)
    }

    private func messageGrid(title: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(isAnswering ? .yellow : .cyan)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(BuddyAssistMessage.allCases) { message in
                    Button(message.title) {
                        buddyAssist.send(message)
                        if isAnswering {
                            isAnswering = false
                            buddyAssist.clearActiveReceivedMessage()
                        }
                    }
                    .font(.caption2.bold())
                    .buttonStyle(.bordered)
                    .disabled(!buddyAssist.canSend)
                }
            }
        }
    }

    private func compassRow(_ title: String, degrees: Double?) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(directionText(degrees))
                .monospacedDigit()
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
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

    private func directionText(_ degrees: Double?) -> String {
        guard let degrees else { return "--" }
        return "\(Int(degrees.rounded()))\u{00B0}"
    }
}
