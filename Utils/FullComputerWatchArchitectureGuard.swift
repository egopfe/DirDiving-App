import Foundation

/// Architectural boundaries for Watch MAIN after Full Computer + shared Bühlmann core (Audit 01 remediation).
enum FullComputerWatchArchitectureGuard {
  /// Watch production roots scanned for duplicate engines / forbidden CCR runtime (excludes `Shared/`).
  static let watchCompileRoots = ["App", "Models", "Services", "Views", "Utils"]

  /// Files excluded from production-root scans (guard definitions list forbidden tokens as string literals).
  static let architectureScanExcludedFileNames: Set<String> = [
    "FullComputerWatchArchitectureGuard.swift",
  ]

  /// Swift files under Watch roots that may reference shared Bühlmann APIs.
  static let approvedSharedCoreConsumerFileNames: Set<String> = [
    "FullComputerDecoSolver.swift",
    "FullComputerRuntimeEngine.swift",
    "FullComputerRuntimeModels.swift",
    "FullComputerGasSwitchPolicy.swift",
    "FullComputerRuntimeCheckpoint.swift",
    "FullComputerRuntimePlan.swift",
    "FullComputerDecoSolverModels.swift",
    "FullComputerGasProfileValidator.swift",
    "DiveManager.swift",
  ]

  static let forbiddenCCRAndRatioTokens = [
    "dirdiving_ccr",
    "ratio_deco",
    "ratiodeco",
    "setpoint",
    "diluent",
  ]

  static let sharedCoreBuhlmannReferenceTokens = [
    "buhlmannengine",
    "buhlmanntissuestate",
    "buhlmannruntimeprojection",
    "buhlmanngas",
    "buhlmannconstants",
    "buhlmanncoreconfiguration",
  ]

  /// Tokens that require an explicit Full Computer runtime allowlist entry (engine / tissue / projection).
  static let strictSharedCoreConsumerTokens = [
    "buhlmannengine",
    "buhlmanntissuestate",
    "buhlmannruntimeprojection",
  ]

  static let duplicateEngineDefinitionPatterns = [
    "struct buhlmannengine",
    "class buhlmannengine",
    "enum buhlmannengine",
  ]

  static let forbiddenReimplementedMathPatterns = [
    "func gfatdepth",
    "func nodecompressionlimit",
    "schreiner loading",
  ]

  static let forbiddenSharedCoreImports = [
    "import swiftui",
    "import watchkit",
    "import uikit",
    "import watchconnectivity",
    "import corelocation",
    "import usernotifications",
  ]

  static func repositoryRoot(from filePath: String = #filePath) -> URL {
    var url = URL(fileURLWithPath: filePath).deletingLastPathComponent()
    let fileManager = FileManager.default
    while url.pathComponents.count > 1 {
      if fileManager.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
        return url
      }
      url.deleteLastPathComponent()
    }
    return URL(fileURLWithPath: filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }

  static func watchSwiftFiles(repoRoot: URL) -> [URL] {
    let fileManager = FileManager.default
    var scanned: [URL] = []
    for root in watchCompileRoots {
      let directory = repoRoot.appendingPathComponent(root, isDirectory: true)
      guard let enumerator = fileManager.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
      ) else { continue }
      for case let url as URL in enumerator {
        guard url.pathExtension == "swift" else { continue }
        if url.path.contains("/iOSApp/") { continue }
        if architectureScanExcludedFileNames.contains(url.lastPathComponent) { continue }
        scanned.append(url)
      }
    }
    return scanned
  }

  static func sharedBuhlmannCoreFiles(repoRoot: URL) -> [URL] {
    let directory = repoRoot.appendingPathComponent("Shared/BuhlmannCore", isDirectory: true)
    guard let contents = try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: nil
    ) else { return [] }
    return contents.filter { $0.pathExtension == "swift" }
  }

  static func codeWithoutLineComments(_ source: String) -> String {
    source
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map { line -> String in
        guard let range = line.range(of: "//") else { return String(line) }
        return String(line[..<range.lowerBound])
      }
      .joined(separator: "\n")
      .lowercased()
  }
}
