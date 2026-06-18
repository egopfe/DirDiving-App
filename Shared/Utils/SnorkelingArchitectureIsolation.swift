import Foundation

/// Static architecture guard for Snorkeling foundation production sources.
enum SnorkelingArchitectureIsolation {
    static let productionSourcePaths = [
        "Shared/Utils/SnorkelingDepthFeed.swift",
        "Shared/Utils/SnorkelingGPSFeed.swift",
        "Shared/Utils/SnorkelingLifecycleStateMachine.swift",
        "Shared/Utils/SnorkelingSessionEngine.swift",
        "Shared/Utils/SnorkelingDomainSupport.swift",
        "Shared/Utils/SnorkelingDomainValidator.swift",
        "Shared/Utils/SnorkelingSchemaMigration.swift",
    ]

    static let forbiddenExecutableSymbols = [
        "DiveManager",
        "DiveLifecycleAlgorithm",
        "DiveLogStore",
        "ApneaSessionEngine",
        "ApneaLogbookStore",
        "FullComputerRuntimeEngine",
        "FullComputerPrediveConfigurationStore",
        "ExplorationStore",
        "BuhlmannEngine",
        "SwiftUI",
        "WatchKit",
        "UIKit",
        "MapKit",
        "WCSession",
    ]

    struct Violation: Equatable {
        let file: String
        let symbol: String
    }

    static func violations(in source: String, file: String = "<inline>") -> [Violation] {
        let executable = stripCommentsAndStringLiterals(from: source)
        return forbiddenExecutableSymbols.compactMap { symbol in
            executable.contains(symbol) ? Violation(file: file, symbol: symbol) : nil
        }
    }

    static func violations(inRepositoryRoot root: URL) throws -> [Violation] {
        var all: [Violation] = []
        for relative in productionSourcePaths {
            let url = root.appendingPathComponent(relative)
            let text = try String(contentsOf: url, encoding: .utf8)
            all.append(contentsOf: violations(in: text, file: relative))
        }
        return all
    }

    /// Removes `//`, `///`, `/* */`, and `/** */` comments plus string literals for executable scanning.
    static func stripCommentsAndStringLiterals(from source: String) -> String {
        var result = ""
        var index = source.startIndex
        let end = source.endIndex

        while index < end {
            let remaining = source[index...]

            if remaining.hasPrefix("///") {
                index = skipLine(from: source, startingAt: index)
                continue
            }

            if remaining.hasPrefix("//") {
                index = skipLine(from: source, startingAt: index)
                continue
            }

            if remaining.hasPrefix("/*") {
                if let close = source[index...].range(of: "*/") {
                    index = close.upperBound
                } else {
                    break
                }
                continue
            }

            if remaining.hasPrefix("\"") {
                let (nextIndex, _) = scanStringLiteral(in: source, from: index)
                result.append(" ")
                index = nextIndex
                continue
            }

            result.append(source[index])
            index = source.index(after: index)
        }

        return result
    }

    private static func skipLine(from source: String, startingAt start: String.Index) -> String.Index {
        var index = start
        while index < source.endIndex, source[index] != "\n" {
            index = source.index(after: index)
        }
        return index
    }

    private static func scanStringLiteral(
        in source: String,
        from start: String.Index
    ) -> (String.Index, String) {
        guard start < source.endIndex, source[start] == "\"" else {
            return (start, "")
        }

        if source[start...].hasPrefix("\"\"\"") {
            var index = source.index(start, offsetBy: 3)
            while index < source.endIndex {
                if source[index...].hasPrefix("\"\"\"") {
                    return (source.index(index, offsetBy: 3), "")
                }
                index = source.index(after: index)
            }
            return (source.endIndex, "")
        }

        var index = source.index(after: start)
        var escaped = false
        while index < source.endIndex {
            let character = source[index]
            if escaped {
                escaped = false
            } else if character == "\\" {
                escaped = true
            } else if character == "\"" {
                return (source.index(after: index), "")
            }
            index = source.index(after: index)
        }
        return (source.endIndex, "")
    }
}
