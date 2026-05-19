import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ExploreView: View {
    @EnvironmentObject private var logStore: DiveLogStore
    @EnvironmentObject private var watchSync: WatchSyncService
    @EnvironmentObject private var navigation: IOSNavigationStore
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue
    @State private var showImporter = false
    @State private var importMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        if routeSummaries.isEmpty {
                            emptyRouteState
                        } else {
                            routeStatusStrip
                            waypointCards
                            routeOverview
                            syncExportStatus
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
                switch result {
                case .success(let url):
                    importRouteCSV(from: url)
                case .failure(let error):
                    importMessage = error.localizedDescription
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline) {
                Text("Route Review")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text("MARINE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(DIRTheme.cyan.opacity(0.12)).overlay(Capsule().stroke(DIRTheme.cyan.opacity(0.45), lineWidth: 1)))
            }
            Text("Route calcolate dai punti GPS entry/exit dei log importati o sincronizzati.")
                .font(.callout)
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 8) {
                statusBadge("WAYPOINTS", color: DIRTheme.cyan)
                statusBadge("ROUTES", color: DIRTheme.green)
                statusBadge("GPS LOGS", color: DIRTheme.yellow)
            }
        }
    }

    private var routeStatusStrip: some View {
        let routes = routeSummaries
        let distance = Formatters.distance(totalDistance, units: unitPreference, prefersLargeUnit: true)
        HStack(spacing: 12) {
            routeStatus("ROUTES", "\(routes.count)", DIRTheme.cyan, "point.topleft.down.curvedto.point.bottomright.up")
            routeStatus("DIST", distance.text, DIRTheme.green, "ruler")
            routeStatus("LATEST", latestBearingText, DIRTheme.yellow, "location.north")
        }
    }

    private var waypointCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            DIRSectionHeader(title: "Waypoint hierarchy", subtitle: "Entry/exit points from real logged GPS data")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(routeSummaries) { route in
                        waypointCard(route.name, Formatters.distance(route.distanceMeters, units: unitPreference).text, route.startDate.formatted(.dateTime.day().month().hour().minute()), DIRTheme.cyan, "mappin.and.ellipse")
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var routeOverview: some View {
        DIRCard("ROUTE REVIEW", icon: "point.topleft.down.curvedto.point.bottomright.up", accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Bearing", value: latestBearingText, unit: nil, color: DIRTheme.cyan, icon: "location.north")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Distance", measurement: Formatters.distance(totalDistance, units: unitPreference), color: DIRTheme.green, icon: "arrow.left.and.right")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Fix", value: "\(routeSummaries.count)", color: DIRTheme.yellow, icon: "flag")
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "Entry", value: routeSummaries.isEmpty ? "--" : "SET", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Exit", value: routeSummaries.isEmpty ? "--" : "SET", color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "Source", value: "LOG", color: DIRTheme.green)
                }
            }
        }
    }

    private var syncExportStatus: some View {
        HStack(spacing: 12) {
            statusCard("ROUTE SOURCE", "\(routeSummaries.count) GPS logs", "applewatch", DIRTheme.cyan)
            statusCard("EXPORT STATUS", "CSV via Logbook", "square.and.arrow.up", DIRTheme.yellow)
        }
    }

    private var emptyRouteState: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 11) {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(DIRTheme.cyan.opacity(0.12)))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nessuna route disponibile")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Route Review usa solo punti GPS entry/exit presenti nei log. Nessun tracking subacqueo viene simulato.")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            VStack(spacing: 9) {
                HStack(spacing: 10) {
                    emptyAction("Sync Watch", "applewatch") {
                        watchSync.retryActivation(logStore: logStore)
                        importMessage = "Sync Apple Watch richiesta. Le route compariranno quando i log includono entry/exit GPS."
                    }
                    emptyAction("Sync iCloud", "icloud.and.arrow.down") {
                        logStore.synchronizeCloud()
                        importMessage = "Sincronizzazione iCloud richiesta per aggiornare i log disponibili."
                    }
                }
                HStack(spacing: 10) {
                    emptyAction("Importa CSV", "square.and.arrow.down") {
                        showImporter = true
                    }
                    emptyAction("Apri Logbook", "list.bullet.rectangle.portrait.fill") {
                        navigation.selectedTab = .logbook
                    }
                }
            }
            if let importMessage {
                Text(importMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.30), lineWidth: 1))
        )
    }

    private var routeSummaries: [RouteSummary] {
        RouteSummaryService.summaries(from: logStore.sessions)
    }

    private var totalDistance: Double {
        routeSummaries.map(\.distanceMeters).reduce(0, +)
    }

    private var latestBearingText: String {
        guard let bearing = routeSummaries.first?.bearingDegrees else { return "--" }
        return Formatters.zero(bearing)
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    private func waypointCard(_ title: String, _ distance: String, _ subtitle: String, _ color: Color, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
            Text(distance)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(color)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
        }
        .frame(width: 150, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.14), DIRTheme.surface.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.48), lineWidth: 1))
                .shadow(color: color.opacity(0.12), radius: 12, x: 0, y: 8)
        )
    }

    private func routeStatus(_ title: String, _ value: String, _ color: Color, _ icon: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .background(Circle().fill(color.opacity(0.13)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value)
                    .font(.callout.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.74))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.34), lineWidth: 1))
        )
    }

    private func statusCard(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        DIRCard(accent: color) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
                Text(value)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.12)).overlay(Capsule().stroke(color.opacity(0.45), lineWidth: 1)))
    }

    private func emptyAction(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.62), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func importRouteCSV(from url: URL) {
        switch DiveImportService.importCSV(from: url) {
        case .success(let summary):
            let alreadyImported = logStore.session(id: summary.session.id) != nil
            logStore.add(summary.session)
            if !alreadyImported {
                watchSync.pushSession(summary.session)
            }
            importMessage = summary.message(alreadyImported: alreadyImported)
            HapticFeedback.success()
        case .failure(let error):
            importMessage = error.localizedDescription
            HapticFeedback.error()
        }
    }

}
