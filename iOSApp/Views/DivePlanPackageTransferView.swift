import SwiftUI

struct DivePlanPackageTransferView: View {
    @EnvironmentObject private var store: PlannerStore
    @EnvironmentObject private var planTransfer: DivePlanPackageWatchTransferService
    @Environment(\.dismiss) private var dismiss

    private var package: DivePlanPackage? { planTransfer.currentPackage }
    private var canSend: Bool {
        guard let package else { return false }
        return (try? DivePlanPackageCodec.validate(package)) != nil
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 6) {
                        Text(DIRIOSLocalizer.string("fc.plan.transfer.title"))
                            .dirScreenTitleStyle()
                            .frame(maxWidth: .infinity)
                    }

                    if let package {
                        planCard(
                            title: DIRIOSLocalizer.string("fc.plan.transfer.bottom_gas"),
                            value: bottomGasLabel(package),
                            accent: DIRTheme.cyan,
                            icon: "cylinder"
                        )
                        planCard(
                            title: DIRIOSLocalizer.string("fc.plan.transfer.deco_gases"),
                            value: decoGasesLabel(package),
                            accent: DIRTheme.green,
                            icon: "cylinder.fill"
                        )
                        planCard(
                            title: DIRIOSLocalizer.string("fc.plan.transfer.gf"),
                            value: "\(Int(package.body.gfLow))/\(Int(package.body.gfHigh))",
                            accent: DIRTheme.yellow,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        planCard(
                            title: DIRIOSLocalizer.string("fc.plan.transfer.plan"),
                            value: planKindLabel(package),
                            accent: Color(red: 0.69, green: 0.32, blue: 0.87),
                            icon: "list.bullet"
                        )

                        if !canSend {
                            Text(DIRIOSLocalizer.string("fc.plan.transfer.validation_failed"))
                                .font(.caption)
                                .foregroundStyle(DIRTheme.orange)
                        }
                    } else {
                        Text(DIRIOSLocalizer.string("fc.plan.transfer.prepare_failed"))
                            .font(.callout)
                            .foregroundStyle(DIRTheme.muted)
                    }

                    Button {
                        planTransfer.sendPreparedPackage()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "applewatch")
                            Text(DIRIOSLocalizer.string("fc.plan.transfer.send"))
                                .font(.callout.weight(.semibold))
                        }
                        .foregroundStyle(DIRTheme.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DIRTheme.cyan.opacity(0.8), lineWidth: 1.2)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSend || isSendDisabled)

                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption)
                        Text(syncStatusText)
                            .font(.caption)
                    }
                    .foregroundStyle(syncStatusColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, DIRTheme.screenPadding)
                .padding(.vertical, 16)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(DIRIOSLocalizer.string("fc.plan.transfer.nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { preparePackage() }
    }

    private var isSendDisabled: Bool {
        switch planTransfer.state {
        case .sending, .awaitingAck:
            return true
        default:
            return false
        }
    }

    private var syncStatusText: String {
        switch planTransfer.state {
        case .idle:
            if let date = planTransfer.lastSuccessfulSyncAt {
                return String(format: DIRIOSLocalizer.string("fc.plan.transfer.last_sync"), formattedSyncDate(date))
            }
            return DIRIOSLocalizer.string("fc.plan.transfer.not_synced")
        case .sending:
            return DIRIOSLocalizer.string("fc.plan.transfer.sending")
        case .awaitingAck:
            return DIRIOSLocalizer.string("fc.plan.transfer.awaiting_ack")
        case .acknowledged(_, _, let syncedAt):
            return String(format: DIRIOSLocalizer.string("fc.plan.transfer.last_sync"), formattedSyncDate(syncedAt))
        case .failed(let message):
            return message
        }
    }

    private var syncStatusColor: Color {
        switch planTransfer.state {
        case .acknowledged:
            return DIRTheme.green
        case .failed:
            return DIRTheme.orange
        case .awaitingAck, .sending:
            return DIRTheme.cyan
        case .idle:
            return planTransfer.lastSuccessfulSyncAt == nil ? DIRTheme.muted : DIRTheme.green
        }
    }

    private func preparePackage() {
        do {
            planTransfer.rememberInputSnapshot(
                input: store.input,
                plan: store.plan,
                modeLabel: store.mode.localizedTabTitle
            )
            try planTransfer.preparePackage(
                input: store.input,
                plan: store.plan,
                modeLabel: store.mode.localizedTabTitle
            )
        } catch {
            planTransfer.markPrepareFailed()
        }
    }

    private func bottomGasLabel(_ package: DivePlanPackage) -> String {
        package.body.gases.first(where: { $0.role == .bottom })?.name ?? "—"
    }

    private func decoGasesLabel(_ package: DivePlanPackage) -> String {
        let deco = package.body.gases
            .filter { $0.role == .deco }
            .sorted { ($0.switchDepthMeters ?? 0) > ($1.switchDepthMeters ?? 0) }
        guard !deco.isEmpty else { return "—" }
        return deco.map { gas in
            if let depth = gas.switchDepthMeters {
                return "\(gas.name)\n\(String(format: DIRIOSLocalizer.string("fc.plan.transfer.switch_at"), Formatters.one(depth)))"
            }
            return gas.name
        }.joined(separator: "\n")
    }

    private func planKindLabel(_ package: DivePlanPackage) -> String {
        package.body.plannerSummary.planKind == "multilevel"
            ? DIRIOSLocalizer.string("fc.plan.transfer.multilevel")
            : DIRIOSLocalizer.string("fc.plan.transfer.single_level")
    }

    private func formattedSyncDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let time = date.formatted(date: .omitted, time: .shortened)
            return DIRIOSLocalizer.string("fc.plan.transfer.sync_today").replacingOccurrences(of: "%@", with: time)
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private func planCard(title: String, value: String, accent: Color, icon: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(accent)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accent.opacity(0.65), lineWidth: 1)
        )
    }
}
