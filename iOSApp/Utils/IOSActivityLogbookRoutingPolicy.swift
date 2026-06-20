import Foundation

/// iOS Companion logbook routing contract (Command 7 remediation).
enum IOSActivityLogbookRoutingPolicy {
    enum LogbookKind: String, CaseIterable, Sendable {
        case diving
        case apnea
        case snorkeling
    }

    static func owningLogbook(for activity: DIRActivityMode) -> LogbookKind {
        switch activity {
        case .diving: return .diving
        case .apnea: return .apnea
        case .snorkeling: return .snorkeling
        }
    }

    static func isRouteAllowed(from source: DIRActivityMode, to target: LogbookKind) -> Bool {
        owningLogbook(for: source) == target
    }

    static let forbiddenCrossRoutes: [(DIRActivityMode, LogbookKind)] = {
        var routes: [(DIRActivityMode, LogbookKind)] = []
        for source in DIRActivityMode.allCases {
            for target in LogbookKind.allCases where !isRouteAllowed(from: source, to: target) {
                routes.append((source, target))
            }
        }
        return routes
    }()

    static func rootViewName(for activity: DIRActivityMode) -> String {
        switch activity {
        case .diving: return "ContentView"
        case .apnea: return "IOSApneaRootView"
        case .snorkeling: return "IOSSnorkelingRootView"
        }
    }

    static func logbookViewName(for kind: LogbookKind) -> String {
        switch kind {
        case .diving: return "LogbookView"
        case .apnea: return "IOSApneaSessionsListView"
        case .snorkeling: return "IOSSnorkelingSessionsListView"
        }
    }
}
