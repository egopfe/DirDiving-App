import SwiftUI

struct BuddyAssistView: View {
    @EnvironmentObject private var buddyAssist: BuddyAssistService
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager
    @State private var isAnswering = false

    private let columns = [
        GridItem(.flexible(), spacing: 7),
        GridItem(.flexible(), spacing: 7)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    header
                    warning
                    pairingPanel
                    buddyLinkPanel
                    compassPanel
                    receivedBanner
                    messageGrid(title: isAnswering ? "ANSWER" : "SEND")
                    controls
                    lastEvent
                    errorMessage
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
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

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("BUDDY ASSIST")
                    .font(.headline.bold())
                    .foregroundStyle(DiveUI.blue)
                Text(buddyAssist.state.rawValue)
                    .font(.caption2.monospacedDigit().bold())
                    .foregroundStyle(buddyAssist.canSend ? DiveUI.green : DiveUI.yellow)
            }
            Spacer()
            Circle()
                .fill(proximityColor)
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 1))
        }
    }

    private var warning: some View {
        DivePanel(stroke: DiveUI.yellow) {
            VStack(spacing: 3) {
                Text("Indicazione di prossimit\u{00E0} sperimentale non affidabile per sicurezza immersione.")
                Text("Pairing solo prima dell'immersione. Non effettuare pairing in immersione.")
            }
            .font(.caption2.bold())
            .foregroundStyle(DiveUI.yellow)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var pairingPanel: some View {
        DivePanel(stroke: dive.isDiveActive ? DiveUI.red : DiveUI.green) {
            VStack(spacing: 6) {
                HStack {
                    Text("SECURE PAIRING")
                        .font(.caption.bold())
                        .foregroundStyle(DiveUI.green)
                    Spacer()
                    Text(buddyAssist.pairingStatusText)
                        .font(.caption2.monospacedDigit().bold())
                        .foregroundStyle(pairingColor)
                }
                HStack {
                    Text("BUDDY")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Text(buddyAssist.isPaired ? buddyAssist.pairedBuddyDisplayName : "--")
                        .font(.caption2.monospacedDigit().bold())
                        .foregroundStyle(DiveUI.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                HStack {
                    Text("SECURITY")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Text(buddyAssist.securityStatusText)
                        .font(.caption2.monospacedDigit().bold())
                        .foregroundStyle(pairingColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                if let code = buddyAssist.pairingConfirmationCode {
                    VStack(spacing: 3) {
                        Text("VERIFY CODE")
                            .font(.caption2.bold())
                            .foregroundStyle(DiveUI.yellow)
                        Text(code)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                        Text("Conferma solo se identico sull'altro Watch.")
                            .font(.caption2)
                            .foregroundStyle(DiveUI.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(DiveUI.yellow.opacity(0.85), lineWidth: 1))
                }
                if let fingerprint = buddyAssist.trustedBuddyFingerprint {
                    HStack {
                        Text("FINGERPRINT")
                        Spacer()
                        Text(fingerprint)
                            .monospacedDigit()
                    }
                    .font(.caption2.bold())
                    .foregroundStyle(DiveUI.secondaryText)
                }
                if dive.isDiveActive {
                    Text("PAIRING BLOCCATO: IMMERSIONE ATTIVA")
                        .font(.caption2.bold())
                        .foregroundStyle(DiveUI.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var buddyLinkPanel: some View {
        DivePanel(stroke: proximityColor) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("BUDDY LINK")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Text(buddyAssist.proximityState.rawValue)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(proximityColor)
                    Text(pingText)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(DiveUI.secondaryText)
                }
                Spacer()
                Text(buddyAssist.buddyLinkStatus)
                    .font(.headline.monospacedDigit().bold())
                    .foregroundStyle(buddyAssist.isBuddyOnline ? DiveUI.green : DiveUI.red)
            }
        }
    }

    private var compassPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            VStack(spacing: 5) {
                HStack {
                    Text("BUSSOLA")
                        .font(.caption.bold())
                        .foregroundStyle(DiveUI.blue)
                    Spacer()
                    Text(directionText(buddyAssist.plausibleDirectionDegrees))
                        .font(.caption.monospacedDigit().bold())
                        .foregroundStyle(DiveUI.yellow)
                }
                compassRow("Ultima direzione", degrees: buddyAssist.lastKnownDirectionDegrees)
                compassRow("Bearing condiviso", degrees: buddyAssist.sharedBearingDegrees)
                compassRow("Heading", degrees: compass.headingDegrees)
                HStack {
                    Text("Direzione plausibile")
                    Spacer()
                    Text(directionText(buddyAssist.plausibleDirectionDegrees))
                        .foregroundStyle(DiveUI.yellow)
                        .monospacedDigit()
                }
                .font(.caption2.bold())
                .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private var receivedBanner: some View {
        if let event = buddyAssist.activeReceivedMessage {
            DivePanel(stroke: event.message.isCritical ? DiveUI.red : DiveUI.green) {
                VStack(spacing: 6) {
                    Text("MESSAGGIO BUDDY")
                        .font(.caption2.bold())
                    Text(event.message.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    HStack(spacing: 8) {
                        DiveCommandButton("ANSWER", color: DiveUI.blue) {
                            isAnswering = true
                        }
                        DiveCommandButton("OK", color: DiveUI.green) {
                            isAnswering = false
                            buddyAssist.clearActiveReceivedMessage()
                        }
                    }
                }
                .foregroundStyle(.white)
            }
        }
    }

    private func messageGrid(title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(isAnswering ? DiveUI.yellow : DiveUI.blue)
            LazyVGrid(columns: columns, spacing: 7) {
                ForEach(BuddyAssistMessage.allCases) { message in
                    DiveCommandButton(message.title, color: message.isCritical ? DiveUI.red : DiveUI.blue) {
                        buddyAssist.send(message)
                        if isAnswering {
                            isAnswering = false
                            buddyAssist.clearActiveReceivedMessage()
                        }
                    }
                    .disabled(!buddyAssist.canSend)
                    .opacity(buddyAssist.canSend ? 1.0 : 0.42)
                }
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 7) {
            HStack(spacing: 7) {
                DiveCommandButton(buddyAssist.hasDiscoveredBuddy ? "CONNECT" : "PAIR", systemImage: "link", color: DiveUI.green) {
                    if buddyAssist.hasDiscoveredBuddy {
                        buddyAssist.connectToDiscoveredBuddy()
                    } else {
                        buddyAssist.startPairing(isDiveActive: dive.isDiveActive)
                    }
                }
                .disabled(dive.isDiveActive || !ExperimentalFeatures.buddyAssistEnabled)
                .opacity(dive.isDiveActive || !ExperimentalFeatures.buddyAssistEnabled ? 0.42 : 1.0)
                DiveCommandButton("TRUST", systemImage: "checkmark.shield", color: DiveUI.yellow) {
                    buddyAssist.confirmSecurePairing()
                }
                .disabled(!buddyAssist.canConfirmPairing || dive.isDiveActive)
                .opacity(buddyAssist.canConfirmPairing && !dive.isDiveActive ? 1.0 : 0.42)
            }
            HStack(spacing: 7) {
                DiveCommandButton("STOP", systemImage: "stop.fill", color: DiveUI.red) {
                    buddyAssist.stopPairing()
                }
                DiveCommandButton("UNPAIR", systemImage: "xmark", color: .white.opacity(0.78)) {
                    buddyAssist.forgetBuddy()
                }
            }
        }
    }

    @ViewBuilder
    private var lastEvent: some View {
        if let last = buddyAssist.events.first {
            Text("\(last.direction.rawValue.uppercased()) \(last.message.title)")
                .font(.caption2.monospacedDigit().bold())
                .foregroundStyle(last.direction == .received ? DiveUI.green : DiveUI.blue)
        }
    }

    @ViewBuilder
    private var errorMessage: some View {
        if let error = buddyAssist.lastErrorMessage {
            Text(error)
                .font(.caption2)
                .foregroundStyle(DiveUI.yellow)
                .multilineTextAlignment(.center)
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
        .foregroundStyle(DiveUI.secondaryText)
    }

    private var proximityColor: Color {
        switch buddyAssist.proximityState {
        case .near: return DiveUI.green
        case .distant: return DiveUI.yellow
        case .disconnected: return DiveUI.red
        }
    }

    private var pairingColor: Color {
        switch buddyAssist.securePairingState {
        case .trusted: return DiveUI.green
        case .confirming, .scanning: return DiveUI.yellow
        case .blocked, .unpaired: return DiveUI.red
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

