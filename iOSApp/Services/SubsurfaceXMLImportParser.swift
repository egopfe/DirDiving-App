import Foundation

struct SubsurfaceXMLImportParser: DivingImportParser {
    let supportedFormats: Set<DivingImportSourceFormat> = [.subsurfaceXML]

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

        let delegate = SubsurfaceXMLParserDelegate(fileName: source.fileName)
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

    private func buildCandidate(from parsed: SubsurfaceXMLParserDelegate.ParsedDive, fileName: String) -> DivingImportCandidate? {
        guard let startDate = parsed.startDate else { return nil }
        guard !parsed.samples.isEmpty else {
            let session = placeholderSession(from: parsed, startDate: startDate)
            let fingerprint = DivingImportFingerprint.make(from: session, sourceDiveID: parsed.diveID, sourceComputerModel: parsed.computerModel)
            return DivingImportCandidate(
                id: UUID(),
                sourceFormat: .subsurfaceXML,
                sourceFileName: fileName,
                sourceDiveID: parsed.diveID,
                sourceComputerModel: parsed.computerModel,
                originalDiveNumber: parsed.diveNumber,
                session: session,
                warnings: [.missingSamples],
                fingerprint: fingerprint,
                isImportable: false
            )
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

        let endDate = sortedSamples.last?.timestamp ?? startDate.addingTimeInterval(parsed.durationSeconds ?? 0)
        let summary = DiveProfileMath.summary(
            samples: sortedSamples,
            startDate: startDate,
            endDate: endDate,
            maxDepthLimit: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )

        var warnings: [DivingImportWarning] = []
        if sortedSamples.count < 3 { warnings.append(.sparseSamples) }
        if parsed.temperatureCelsius == nil { warnings.append(.missingTemperature) }
        if parsed.entryGPS == nil && parsed.exitGPS == nil { warnings.append(.missingGPS) }
        if parsed.gasLabel == nil { warnings.append(.missingGas) }

        let session = DiveSession(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            durationSeconds: parsed.durationSeconds ?? summary.durationSeconds,
            maxDepthMeters: parsed.maxDepthMeters ?? summary.maxDepthMeters,
            avgDepthMeters: parsed.avgDepthMeters ?? summary.averageDepthMeters,
            avgWaterTemperatureCelsius: parsed.temperatureCelsius ?? summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: parsed.entryGPS,
            exitGPS: parsed.exitGPS,
            entryGPSFixSource: parsed.entryGPS == nil ? .noFix : .fallback,
            exitGPSFixSource: parsed.exitGPS == nil ? .noFix : .fallback,
            samples: sortedSamples,
            siteName: parsed.siteName,
            buddy: parsed.buddy,
            notes: parsed.notes,
            gasLabel: parsed.gasLabel ?? .oc
        )

        return DivingImportCandidate.build(
            sourceFormat: .subsurfaceXML,
            sourceFileName: fileName,
            session: session,
            sourceDiveID: parsed.diveID,
            sourceComputerModel: parsed.computerModel,
            originalDiveNumber: parsed.diveNumber,
            warnings: warnings
        )
    }

    private func placeholderSession(from parsed: SubsurfaceXMLParserDelegate.ParsedDive, startDate: Date) -> DiveSession {
        DiveSession(
            id: UUID(),
            startDate: startDate,
            endDate: startDate.addingTimeInterval(parsed.durationSeconds ?? 0),
            durationSeconds: parsed.durationSeconds ?? 0,
            maxDepthMeters: parsed.maxDepthMeters ?? 0,
            avgDepthMeters: parsed.avgDepthMeters ?? 0,
            avgWaterTemperatureCelsius: parsed.temperatureCelsius,
            ttv: 0,
            entryGPS: parsed.entryGPS,
            exitGPS: parsed.exitGPS,
            samples: [],
            siteName: parsed.siteName,
            buddy: parsed.buddy,
            notes: parsed.notes,
            gasLabel: parsed.gasLabel ?? .oc
        )
    }
}

final class SubsurfaceXMLParserDelegate: NSObject, XMLParserDelegate {
    struct ParsedSample {
        var offsetSeconds: TimeInterval
        var depthMeters: Double
        var temperatureCelsius: Double?
    }

    struct ParsedDive {
        var diveID: String?
        var diveNumber: Int?
        var startDate: Date?
        var durationSeconds: TimeInterval?
        var maxDepthMeters: Double?
        var avgDepthMeters: Double?
        var temperatureCelsius: Double?
        var siteName: String?
        var buddy: String?
        var notes: String?
        var gasLabel: DiveGasLabel?
        var computerModel: String?
        var entryGPS: GPSPoint?
        var exitGPS: GPSPoint?
        var samples: [ParsedSample] = []
    }

    private let fileName: String
    private(set) var parsedDives: [ParsedDive] = []
    private(set) var warnings: [String] = []

    private var currentDive: ParsedDive?
    private var currentElement = ""
    private var currentText = ""
    private var inDiveComputer = false

    init(fileName: String) {
        self.fileName = fileName
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName.lowercased()
        currentText = ""
        switch currentElement {
        case "dive":
            var dive = ParsedDive()
            dive.diveID = attributeDict["id"] ?? attributeDict["number"]
            if let number = attributeDict["number"], let parsed = Int(number) {
                dive.diveNumber = parsed
            }
            dive.startDate = DivingImportUnitParser.parseDateTime(
                date: attributeDict["date"],
                time: attributeDict["time"]
            )
            if let duration = attributeDict["duration"] {
                dive.durationSeconds = DivingImportUnitParser.parseDurationSeconds(duration)
            }
            if let maxDepth = attributeDict["maxdepth"] ?? attributeDict["max_depth"] {
                dive.maxDepthMeters = DivingImportUnitParser.parseDepthMeters(maxDepth)
            }
            currentDive = dive
        case "divecomputer", "computer":
            inDiveComputer = true
            currentDive?.computerModel = attributeDict["model"] ?? attributeDict["type"]
        case "sample", "waypoint":
            guard inDiveComputer || currentDive != nil else { return }
            let offset = DivingImportUnitParser.parseSampleOffsetSeconds(attributeDict["time"] ?? attributeDict["divetime"] ?? "0") ?? 0
            let depth = DivingImportUnitParser.parseDepthMeters(attributeDict["depth"] ?? attributeDict["depth_m"] ?? "0") ?? 0
            let temp = attributeDict["temp"].flatMap { DivingImportUnitParser.parseTemperatureCelsius($0) }
            currentDive?.samples.append(ParsedSample(offsetSeconds: offset, depthMeters: depth, temperatureCelsius: temp))
        case "location", "site":
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
            inDiveComputer = false
        case "divecomputer", "computer":
            inDiveComputer = false
        case "location", "site":
            if !text.isEmpty { currentDive?.siteName = String(text.prefix(200)) }
        case "buddy":
            if !text.isEmpty { currentDive?.buddy = String(text.prefix(200)) }
        case "notes", "note":
            if !text.isEmpty { currentDive?.notes = String(text.prefix(DivingImportLimits.maxImportedNotesLength)) }
        case "gas":
            if let label = DiveGasLabel(rawValue: text.uppercased()) {
                currentDive?.gasLabel = label
            } else {
                warnings.append("Unsupported gas ignored")
            }
        case "meandepth", "avgdepth":
            if let depth = DivingImportUnitParser.parseDepthMeters(text) {
                currentDive?.avgDepthMeters = depth
            }
        case "maxdepth":
            if let depth = DivingImportUnitParser.parseDepthMeters(text) {
                currentDive?.maxDepthMeters = depth
            }
        case "temperature", "temp":
            if let temp = DivingImportUnitParser.parseTemperatureCelsius(text) {
                currentDive?.temperatureCelsius = temp
            }
        default:
            break
        }
        currentText = ""
    }
}
