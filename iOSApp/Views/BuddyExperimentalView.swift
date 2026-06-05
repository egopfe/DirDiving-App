import SwiftUI

struct BuddyExperimentalView: View {
    @EnvironmentObject private var store: BuddyExperimentalStore

    private let messageColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        DIRWarningBox(text: "Buddy Assist, Buddy Link e prossimita BLE sono funzioni sperimentali. Non usarle come sistema di sicurezza, soccorso o navigazione subacquea.")
                        securePairingCard
                        linkCard
                        compassCard
                        messagesCard
                        syncCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Buddy Lab")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Experimental iOS companion for buddy state, messages and direction previews")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
            }
            Spacer()
            statusDot(store.status.signalState.color)
        }
    }

    private var securePairingCard: some View {
        DIRCard("SECURE PAIRING", icon: "checkmark.shield", accent: DIRTheme.green) {
            VStack(spacing: 12) {
                HStack {
                    labelValue("Buddy", store.status.buddyName)
                    statePill(store.status.pairingState.rawValue, color: store.status.pairingState.color)
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 12) {
                    codeBlock(title: "VERIFY CODE", value: store.status.confirmationCode, color: DIRTheme.yellow)
                    codeBlock(title: "FINGERPRINT", value: store.status.keyFingerprint, color: DIRTheme.cyan)
                }
                Text("Il pairing viene completato su Apple Watch prima dell'immersione. iPhone mostra stato, codice e fingerprint sincronizzati, senza eseguire pairing BLE underwater.")
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    actionButton("VERIFY", color: DIRTheme.yellow) { store.markPairingForReview() }
                    actionButton("TRUSTED", color: DIRTheme.green) { store.markTrusted() }
                }
            }
        }
    }

    private var linkCard: some View {
        DIRCard("BUDDY LINK", icon: "dot.radiowaves.left.and.right", accent: store.status.signalState.color) {
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Stato", value: store.status.linkState.rawValue, color: store.status.linkState == .online ? DIRTheme.green : DIRTheme.red)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "RSSI", value: "\(store.status.lastRSSI)", unit: "dBm", color: store.status.signalState.color)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Ping", value: "\(store.status.lastPingSeconds)", unit: "s", color: DIRTheme.cyan)
                }
                HStack {
                    statusDot(store.status.signalState.color)
                    Text(store.status.signalState.rawValue)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(store.status.signalState.color)
                    Spacer()
                    actionButton("SIM LOST", color: DIRTheme.red) { store.simulateLostLink() }
                        .frame(width: 112)
                }
            }
        }
    }

    private var compassCard: some View {
        DIRCard("ULTIMA DIREZIONE PLAUSIBILE", icon: "safari", accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                directionRow("Heading", degrees: store.status.headingDegrees, color: DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                directionRow("Bearing condiviso", degrees: store.status.sharedBearingDegrees, color: DIRTheme.yellow)
                Divider().overlay(DIRTheme.hairline)
                directionRow("Direzione plausibile", degrees: store.status.plausibleDirectionDegrees, color: DIRTheme.green)
            }
        }
    }

    private var messagesCard: some View {
        DIRCard("PRESET MESSAGES", icon: "message", accent: DIRTheme.yellow) {
            VStack(alignment: .leading, spacing: 12) {
                LazyVGrid(columns: messageColumns, spacing: 10) {
                    ForEach(store.preparedMessages) { message in
                        Button {
                            store.prepare(message)
                        } label: {
                            Text(message.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(message.isCritical ? DIRTheme.red : DIRTheme.cyan)
                                .lineLimit(1)
                                .minimumScaleFactor(0.68)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill((message.isCritical ? DIRTheme.red : DIRTheme.cyan).opacity(0.12))
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke((message.isCritical ? DIRTheme.red : DIRTheme.cyan).opacity(0.72), lineWidth: 1))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!store.canPrepareMessages)
                        .opacity(store.canPrepareMessages ? 1.0 : 0.42)
                    }
                }
                labelValue("Pronto", store.selectedMessage.rawValue)
            }
        }
    }

    private var syncCard: some View {
        DIRCard("WATCH EXPERIMENTAL SYNC", icon: "applewatch", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 10) {
                labelValue("Branch Watch", "codex/experimental-features")
                labelValue("Branch iOS", "codex/ios-experimental-features")
                labelValue("Ultima azione", store.lastAction)
                Text("Questa schermata prepara e visualizza dati companion. Il pairing sicuro, BLE e invio messaggi restano responsabilita del Watch experimental.")
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func labelValue(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
            Spacer(minLength: 12)
            Text(value)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
    }

    private func directionRow(_ label: String, degrees: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text("\(degrees) deg")
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(color)
        }
        .padding(.vertical, 10)
    }

    private func codeBlock(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 7) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.55), lineWidth: 1)))
    }

    private func statePill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.13)).overlay(Capsule().stroke(color.opacity(0.75), lineWidth: 1)))
    }

    private func statusDot(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 18, height: 18)
            .shadow(color: color.opacity(0.55), radius: 8)
    }

    private func actionButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.7), lineWidth: 1)))
        }
        .buttonStyle(.plain)
    }
}
