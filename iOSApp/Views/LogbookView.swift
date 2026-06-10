import SwiftUI

private struct LogbookMonthSection: Identifiable {
    let id: String
    let title: String
    let sessions: [DiveSession]
}

struct LogbookView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @Environment(\.locale) private var locale
    @State private var search = ""
    @State private var showManualDiveEditor = false
    @State private var pendingDeleteID: UUID?

    private var filtered: [DiveSession] {
        guard !search.isEmpty else { return logStore.sessions }
        return logStore.sessions.filter { matchesSearch($0, query: search) }
    }

    private func matchesSearch(_ session: DiveSession, query: String) -> Bool {
        if (session.siteName ?? "").localizedCaseInsensitiveContains(query) { return true }
        if (session.buddy ?? "").localizedCaseInsensitiveContains(query) { return true }
        if (session.notes ?? "").localizedCaseInsensitiveContains(query) { return true }
        if (session.equipmentUsed ?? "").localizedCaseInsensitiveContains(query) { return true }
        if session.gasLabel.rawValue.localizedCaseInsensitiveContains(query) { return true }
        return false
    }

    private var hasMixedDemoAndRealDives: Bool {
        let hasDemo = logStore.sessions.contains { $0.isDemoDive }
        let hasReal = logStore.sessions.contains { !$0.isDemoDive }
        return hasDemo && hasReal
    }

    private func makeMonthSections(locale: Locale) -> [LogbookMonthSection] {
        let cal = Calendar.current
        var buckets: [String: [DiveSession]] = [:]
        for session in filtered {
            let c = cal.dateComponents([.year, .month], from: session.startDate)
            let key = String(format: "%04d-%02d", c.year ?? 0, c.month ?? 0)
            buckets[key, default: []].append(session)
        }
        let keys = buckets.keys.sorted(by: >)
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return keys.compactMap { key -> LogbookMonthSection? in
            let parts = key.split(separator: "-")
            guard parts.count == 2,
                  let y = Int(parts[0]),
                  let m = Int(parts[1]),
                  let date = cal.date(from: DateComponents(year: y, month: m, day: 1)) else { return nil }
            let title = formatter.string(from: date).uppercased()
            let sessions = (buckets[key] ?? []).sorted { $0.startDate > $1.startDate }
            return LogbookMonthSection(id: key, title: title, sessions: sessions)
        }
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if hasMixedDemoAndRealDives {
                            mixedDemoBanner
                        }
                        DIRSearchBar(text: $search)
                        csvImportSection
                        if filtered.isEmpty {
                            emptyLogbook
                        } else {
                            ForEach(makeMonthSections(locale: locale)) { section in
                                Text(section.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .padding(.top, 8)
                                ForEach(Array(section.sessions.enumerated()), id: \.element.id) { index, session in
                                    HStack(spacing: 8) {
                                        NavigationLink { DiveDetailView(session: session) } label: {
                                            DiveLogCard(session: session, index: index)
                                        }
                                        .buttonStyle(.plain)
                                        if !session.isDemoDive {
                                            Button {
                                                pendingDeleteID = session.id
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.body.weight(.semibold))
                                                    .foregroundStyle(DIRTheme.red)
                                                    .frame(width: 36, height: 36)
                                            }
                                            .buttonStyle(.plain)
                                            .accessibilityLabel(DIRIOSLocalizer.string("logbook.delete.button.a11y"))
                                        }
                                    }
                                    .contextMenu {
                                        if !session.isDemoDive {
                                            Button(role: .destructive) {
                                                pendingDeleteID = session.id
                                            } label: {
                                                Label(DIRIOSLocalizer.string("logbook.delete.button.a11y"), systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showManualDiveEditor) {
                ManualDiveEditorView()
            }
            .confirmationDialog(
                DIRIOSLocalizer.string("logbook.delete.confirm.title"),
                isPresented: Binding(
                    get: { pendingDeleteID != nil },
                    set: { if !$0 { pendingDeleteID = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(DIRIOSLocalizer.string("logbook.delete.confirm.action"), role: .destructive) {
                    if let id = pendingDeleteID {
                        logStore.delete(id: id)
                    }
                    pendingDeleteID = nil
                }
                Button(DIRIOSLocalizer.string("logbook.delete.cancel"), role: .cancel) {
                    pendingDeleteID = nil
                }
            } message: {
                Text(DIRIOSLocalizer.string("logbook.delete.confirm.message"))
            }
        }
        .dirCompanionTabRoot()
    }

    private var csvImportSection: some View {
        CSVImportPanel()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(DIRIOSLocalizer.string("logbook.title"))
                    .dirScreenTitleStyle()
                Spacer()
                Button {
                    showManualDiveEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(DIRTheme.cyan)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(DIRIOSLocalizer.string("manual_dive.add.title")))
            }
            Text(DIRIOSLocalizer.string("logbook.header.subtitle"))
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
        }
    }

    private var emptyLogbook: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(DIRIOSLocalizer.string("logbook.empty.title"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            Text(DIRIOSLocalizer.string("logbook.empty.hint"))
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.hairline, lineWidth: 1))
        )
        .padding(.top, 8)
    }

    private var mixedDemoBanner: some View {
        Text(DIRIOSLocalizer.string("logbook.demo.mixed.banner"))
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.yellow)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                    .fill(DIRTheme.yellow.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.yellow.opacity(0.45), lineWidth: 1))
            )
            .accessibilityLabel(DIRIOSLocalizer.string("logbook.demo.mixed.banner"))
    }
}

struct DiveLogCard: View {
    @Environment(\.locale) private var locale
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    let session: DiveSession
    let index: Int

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    var body: some View {
        HStack(spacing: 12) {
            dateBlock
            DiveThumbnail(index: index)
                .frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(session.siteName ?? DIRIOSLocalizer.string("detail.default_site"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if session.isDemoDive {
                        Text(DIRIOSLocalizer.string("logbook.badge.demo"))
                            .font(DIRTypography.microBadge)
                            .foregroundStyle(DIRTheme.green)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.green, lineWidth: 1))
                            .accessibilityLabel(DIRIOSLocalizer.string("logbook.badge.demo.a11y"))
                    } else if session.isManual, !session.hasDepthProfile {
                        Text(DIRIOSLocalizer.string("logbook.badge.manual.nodepth"))
                            .font(DIRTypography.microBadge)
                            .foregroundStyle(DIRTheme.cyan)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.cyan, lineWidth: 1))
                    } else if session.isManual {
                        Text(DIRIOSLocalizer.string("logbook.badge.manual"))
                            .font(DIRTypography.microBadge)
                            .foregroundStyle(DIRTheme.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.orange, lineWidth: 1))
                    }
                    if session.buddy != nil {
                        Text(DIRIOSLocalizer.string("detail.buddy.badge"))
                            .font(DIRTypography.microBadge)
                            .foregroundStyle(DIRTheme.yellow)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(DIRTheme.yellow, lineWidth: 1))
                    }
                }
                Text(maxDepthLine)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.86))
                HStack {
                    Text(DIRIOSLocalizer.formatted("logbook.card.duration", Formatters.time(session.durationSeconds)))
                    Spacer()
                    Text(session.gasLabel.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.86))
            }
            Spacer(minLength: 6)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
                .shadow(color: DIRTheme.cyan.opacity(0.06), radius: 10, x: 0, y: 6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(consolidatedAccessibilityLabel)
    }

    private var consolidatedAccessibilityLabel: String {
        let site = session.siteName ?? DIRIOSLocalizer.string("detail.default_site")
        let date = session.startDate.formatted(date: .abbreviated, time: .shortened)
        let duration = DIRIOSLocalizer.formatted("logbook.card.duration", Formatters.time(session.durationSeconds))
        var parts = [site, date, maxDepthLine, duration, session.gasLabel.rawValue]
        if session.isDemoDive {
            parts.append(DIRIOSLocalizer.string("logbook.badge.demo.a11y"))
        } else if session.isManual, !session.hasDepthProfile {
            parts.append(DIRIOSLocalizer.string("logbook.badge.manual.nodepth"))
        } else if session.isManual {
            parts.append(DIRIOSLocalizer.string("logbook.badge.manual"))
        }
        if session.buddy != nil {
            parts.append(DIRIOSLocalizer.string("detail.buddy.badge"))
        }
        return parts.joined(separator: ", ")
    }

    private var maxDepthLine: String {
        if session.isManual, !session.hasDepthProfile {
            return DIRIOSLocalizer.string("logbook.card.runtime_gps_only")
        }
        return DIRIOSLocalizer.formatted("logbook.card.max_depth", Formatters.depth(session.maxDepthMeters, units: unitPreference).text)
    }

    private var dateBlock: some View {
        VStack(spacing: 1) {
            Text(session.startDate.formatted(.dateTime.day()))
                .font(DIRTypography.metricValue)
                .foregroundStyle(.white)
            Text(session.startDate.formatted(.dateTime.month(.abbreviated).locale(locale)).uppercased())
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(Formatters.clock(session.startDate))
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(width: 38)
    }
}

struct DiveThumbnail: View {
    let index: Int

    private var colors: [Color] {
        [
            [DIRTheme.cyan, DIRTheme.surface2],
            [DIRTheme.cyan.opacity(0.85), DIRTheme.surface],
            [DIRTheme.green.opacity(0.75), DIRTheme.surface2],
            [DIRTheme.cyan.opacity(0.65), DIRTheme.background]
        ][index % 4]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 52, height: 52)
                .offset(x: -26, y: -30)
            Image(systemName: index == 2 ? "water.waves" : "photo")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .rotationEffect(.degrees(index == 2 ? -18 : 0))
            ForEach(0..<5) { bubble in
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: CGFloat(3 + bubble), height: CGFloat(3 + bubble))
                    .offset(x: CGFloat(18 - bubble * 8), y: CGFloat(-22 + bubble * 9))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
