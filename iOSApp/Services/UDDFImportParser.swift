import Foundation

struct UDDFImportParser: DivingImportParser {
    let supportedFormats: Set<DivingImportSourceFormat> = [.uddf]

    func previewImport(from url: URL, source: DivingImportSource) -> Result<DivingImportPreviewResult, DivingImportError> {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }

        if DiveCSVImportBounds.preflightFileSize(at: url) == .fileTooLarge {
            return .failure(.fileTooLarge)
        }

        guard let data = try? Data(contentsOf: url, options: [.mappedIfSafe]) else {
            return .failure(.unreadableFile)
        }
        if data.count > IOSAlgorithmConfiguration.maxImportBytes {
            return .failure(.fileTooLarge)
        }

        let delegate = UDDFXMLParserDelegate(fileName: source.fileName)
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else {
            return .failure(.malformedFile(DIRIOSLocalizer.string("diving.import.error.unreadable")))
        }

        var candidates: [DivingImportCandidate] = []
        var skipped = 0
        for parsed in delegate.parsedDives.prefix(DivingImportLimits.maxCandidatesPerFile) {
            if let candidate = buildCandidate(from: parsed, fileName: source.fileName) {
                candidates.append(candidate)
            } else {
                skipped += 1
            }
        }
        guard !candidates.isEmpty else {
            return .failure(.emptyImport)
        }
        return .success(
            DivingImportPreviewResult(
                source: source,
                candidates: candidates,
                parseWarnings: delegate.warnings,
                skippedCount: skipped
            )
        )
    }

    private func buildCandidate(from parsed: UDDFXMLParserDelegate.ParsedDive, fileName: String) -> DivingImportCandidate? {
        guard let startDate = parsed.startDate else { return nil }
        guard !parsed.samples.isEmpty else {
            return nil
        }

        let sortedSamples = DiveProfileMath.sanitizedSamples(
            parsed.samples.map { sample in
                DiveSample(
                    timestamp: startDate.addingTimeInterval(sample.offsetSeconds),
                    depthMeters: sample.depthMeters,
                    temperatureCelsius: sample.temperatureCelsius
                )
            },
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        guard !sortedSamples.isEmpty else { return nil }

        let endDate = sortedSamples.last?.timestamp ?? startDate
        let summary = DiveProfileMath.summary(
            samples: sortedSamples,
            startDate: startDate,
            endDate: endDate,
            maxDepthLimit: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )

        var warnings: [DivingImportWarning] = []
        if sortedSamples.count < 3 { warnings.append(.sparseSamples) }
        if parsed.temperatureCelsius == nil { warnings.append(.missingTemperature) }
        if parsed.gasLabel == nil { warnings.append(.missingGas) }
        warnings.append(.unsupportedFieldIgnored)

        let session = DiveSession(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            durationSeconds: parsed.durationSeconds ?? summary.durationSeconds,
            maxDepthMeters: parsed.maxDepthMeters ?? summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: parsed.temperatureCelsius ?? summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: sortedSamples,
            siteName: parsed.siteName,
            buddy: parsed.buddy,
            notes: parsed.notes,
            gasLabel: parsed.gasLabel ?? .oc
        )

        return DivingImportCandidate.build(
            sourceFormat: .uddf,
            sourceFileName: fileName,
            session: session,
            sourceDiveID: parsed.diveID,
            sourceComputerModel: parsed.computerModel,
            warnings: warnings
        )
    }
}

final class UDDFXMLParserDelegate: NSObject, XMLParserDelegate {
    struct ParsedSample {
        var offsetSeconds: TimeInterval
        var depthMeters: Double
        var temperatureCelsius: Double?
    }

    struct ParsedDive {
        var diveID: String?
        var startDate: Date?
        var durationSeconds: TimeInterval?
        var maxDepthMeters: Double?
        var temperatureCelsius: Double?
        var siteName: String?
        var buddy: String?
        var notes: String?
        var gasLabel: DiveGasLabel?
        var computerModel: String?
        var samples: [ParsedSample] = []
    }

    private let fileName: String
    private(set) var parsedDives: [ParsedDive] = []
    private(set) var warnings: [String] = []

    private var currentDive: ParsedDive?
    private var currentText = ""
    private var inSamples = false

    init(fileName: String) {
        self.fileName = fileName
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let element = elementName.lowercased()
        currentText = ""
        switch element {
        case "dive":
            currentDive = ParsedDive(diveID: attributeDict["id"])
        case "datetime":
            break
        case "samples", "waypoints":
            inSamples = true
        case "sample", "waypoint":
            guard inSamples else { return }
            let offset = Double(attributeDict["divetime"] ?? attributeDict["time"] ?? "0") ?? 0
            let depth = DivingImportUnitParser.parseDepthMeters(attributeDict["depth"] ?? "0") ?? 0
            let temp = attributeDict["temperature"].flatMap { DivingImportUnitParser.parseTemperatureCelsius($0) }
            currentDive?.samples.append(ParsedSample(offsetSeconds: offset, depthMeters: depth, temperatureCelsius: temp))
        case "site", "location":
            break
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let element = elementName.lowercased()
        let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        switch element {
        case "dive":
            if let dive = currentDive {
                parsedDives.append(dive)
            }
            currentDive = nil
            inSamples = false
        case "samples", "waypoints":
            inSamples = false
        case "datetime":
            if let date = ISO8601DateFormatter().date(from: text) ?? DivingImportUnitParser.parseDateTime(date: text, time: nil) {
                currentDive?.startDate = date
            } else {
                warnings.append("Missing or invalid start date")
            }
        case "site", "location", "sitename":
            if !text.isEmpty { currentDive?.siteName = String(text.prefix(200)) }
        case "buddy", "partner":
            if !text.isEmpty { currentDive?.buddy = String(text.prefix(200)) }
        case "notes", "note":
            if !text.isEmpty { currentDive?.notes = String(text.prefix(DivingImportLimits.maxImportedNotesLength)) }
        case "depth":
            if inSamples, let depth = DivingImportUnitParser.parseDepthMeters(text) {
                let offset = Double(currentDive?.samples.count ?? 0)
                currentDive?.samples.append(ParsedSample(offsetSeconds: offset, depthMeters: depth, temperatureCelsius: nil))
            } else if let depth = DivingImportUnitParser.parseDepthMeters(text) {
                currentDive?.maxDepthMeters = depth
            }
        case "divetime", "duration":
            if inSamples, let offset = Double(text) {
                if var last = currentDive?.samples.popLast() {
                    last.offsetSeconds = offset
                    currentDive?.samples.append(last)
                }
            } else {
                currentDive?.durationSeconds = DivingImportUnitParser.parseDurationSeconds(text)
            }
        case "temperature":
            if let temp = DivingImportUnitParser.parseTemperatureCelsius(text) {
                currentDive?.temperatureCelsius = temp
            }
        case "manufacturer", "model":
            if !text.isEmpty {
                let existing = currentDive?.computerModel ?? ""
                currentDive?.computerModel = [existing, text].filter { !$0.isEmpty }.joined(separator: " ")
            }
        default:
            break
        }
        currentText = ""
    }
}
