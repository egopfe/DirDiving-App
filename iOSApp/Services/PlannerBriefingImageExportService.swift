import UIKit

struct PlannerBriefingDecoStopExportRow: Hashable {
    let depthLabel: String
    let timeLabel: String
    let gasLabel: String
    let ppO2Label: String
}

struct PlannerBriefingRuntimeExportRow: Hashable {
    let kindLabel: String
    let depthLabel: String
    let timeLabel: String
    let gasLabel: String
}

struct PlannerBriefingImageExportInput: Hashable {
    let modeLabel: String
    let plannerSessionId: UUID?
    let decoStopRows: [PlannerBriefingDecoStopExportRow]
    let runtimeRows: [PlannerBriefingRuntimeExportRow]
    let includesDecoStopsInRuntime: Bool
}

enum PlannerBriefingImageExportService {
    static func export(input: PlannerBriefingImageExportInput) throws -> PlannerBriefingExportPackage {
        let packageId = UUID()
        let generatedAt = Date()
        var cardMetas: [PlannerBriefingCardMetadata] = []
        var files: [URL] = []
        var order = 0

        if !input.decoStopRows.isEmpty {
            let chunks = chunked(input.decoStopRows, size: PlannerBriefingTransferSupport.maxRowsPerCard)
            for (index, chunk) in chunks.enumerated() {
                let title = cardTitle(
                    base: DIRIOSLocalizer.string("planner.deco_stops.title"),
                    index: index + 1,
                    total: chunks.count
                )
                let png = try renderDecoCard(
                    title: title,
                    modeLabel: input.modeLabel,
                    generatedAt: generatedAt,
                    rows: chunk
                )
                let url = try writePNG(png, name: "deco_\(index + 1).png", packageId: packageId)
                order += 1
                let meta = try PlannerBriefingTransferSupport.makeCardMetadata(
                    fileURL: url,
                    title: title,
                    kind: .decoStops,
                    order: order
                )
                cardMetas.append(meta)
                files.append(url)
            }
        }

        if !input.runtimeRows.isEmpty {
            let chunks = chunked(input.runtimeRows, size: PlannerBriefingTransferSupport.maxRowsPerCard)
            for (index, chunk) in chunks.enumerated() {
                let title = cardTitle(
                    base: DIRIOSLocalizer.string("planner.runtime.title"),
                    index: index + 1,
                    total: chunks.count
                )
                let png = try renderRuntimeCard(
                    title: title,
                    modeLabel: input.modeLabel,
                    generatedAt: generatedAt,
                    rows: chunk,
                    includesDecoStops: input.includesDecoStopsInRuntime
                )
                let url = try writePNG(png, name: "runtime_\(index + 1).png", packageId: packageId)
                order += 1
                let meta = try PlannerBriefingTransferSupport.makeCardMetadata(
                    fileURL: url,
                    title: title,
                    kind: .runtime,
                    order: order
                )
                cardMetas.append(meta)
                files.append(url)
            }
        }

        guard !files.isEmpty else {
            throw PlannerBriefingValidationError.manifestCardMismatch
        }

        let totalBytes = files.reduce(0) { partial, url in
            partial + ((try? Data(contentsOf: url).count) ?? 0)
        }
        guard totalBytes <= PlannerBriefingTransferSupport.maxPackageBytes else {
            throw PlannerBriefingValidationError.oversizedPackage
        }

        let manifest = PlannerBriefingCardManifest(
            id: packageId,
            plannerSessionId: input.plannerSessionId,
            generatedAt: generatedAt,
            modeLabel: input.modeLabel,
            title: DIRIOSLocalizer.string("planner.watch_briefing.manifest_title"),
            subtitle: DIRIOSLocalizer.string("planner.watch_briefing.ref_only"),
            referenceOnly: true,
            cards: cardMetas.sorted { $0.order < $1.order }
        )
        return PlannerBriefingExportPackage(manifest: manifest, imageFiles: files)
    }

    static func decoRows(from presentationRows: [DecoStopPresentationRow]) -> [PlannerBriefingDecoStopExportRow] {
        presentationRows.map {
            PlannerBriefingDecoStopExportRow(
                depthLabel: $0.depthLabel,
                timeLabel: $0.timeLabel,
                gasLabel: $0.gasLabel,
                ppO2Label: $0.ppO2Label
            )
        }
    }

    static func runtimeRows(from ascentRows: [PlannerAscentTableRow]) -> [PlannerBriefingRuntimeExportRow] {
        ascentRows.map {
            PlannerBriefingRuntimeExportRow(
                kindLabel: $0.kind.localizedTitle,
                depthLabel: $0.depthLabel,
                timeLabel: $0.timeLabel,
                gasLabel: $0.gas
            )
        }
    }

    private static func generatedAtLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private static func cardTitle(base: String, index: Int, total: Int) -> String {
        total > 1 ? "\(base) \(index)/\(total)" : base
    }

    private static func chunked<T>(_ values: [T], size: Int) -> [[T]] {
        guard size > 0, !values.isEmpty else { return [] }
        var result: [[T]] = []
        var index = 0
        while index < values.count {
            let end = min(index + size, values.count)
            result.append(Array(values[index..<end]))
            index = end
        }
        return result
    }

    private static func writePNG(_ image: UIImage, name: String, packageId: UUID) throws -> URL {
        guard let data = image.pngData() else {
            throw PlannerBriefingValidationError.invalidFileType
        }
        guard data.count <= PlannerBriefingTransferSupport.maxImageBytes else {
            throw PlannerBriefingValidationError.oversizedCard
        }
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("planner_briefing_\(packageId.uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(name)
        try data.write(to: url, options: [.atomic])
        return url
    }

    private static func renderDecoCard(
        title: String,
        modeLabel: String,
        generatedAt: Date,
        rows: [PlannerBriefingDecoStopExportRow]
    ) throws -> UIImage {
        try renderCard(
            title: title,
            modeLabel: modeLabel,
            generatedAt: generatedAt,
            columnHeaders: [
                DIRIOSLocalizer.string("planner.briefing_card.depth"),
                DIRIOSLocalizer.string("planner.briefing_card.time"),
                DIRIOSLocalizer.string("planner.briefing_card.gas"),
                "PPO₂",
            ],
            rowTexts: rows.map { [$0.depthLabel, $0.timeLabel, $0.gasLabel, $0.ppO2Label] },
            includeNotCertifiedFooter: true
        )
    }

    private static func renderRuntimeCard(
        title: String,
        modeLabel: String,
        generatedAt: Date,
        rows: [PlannerBriefingRuntimeExportRow],
        includesDecoStops: Bool
    ) throws -> UIImage {
        try renderCard(
            title: title,
            modeLabel: modeLabel,
            generatedAt: generatedAt,
            columnHeaders: [
                DIRIOSLocalizer.string("planner.briefing_card.phase"),
                DIRIOSLocalizer.string("planner.briefing_card.depth"),
                DIRIOSLocalizer.string("planner.briefing_card.time"),
                DIRIOSLocalizer.string("planner.briefing_card.gas"),
            ],
            rowTexts: rows.map { [$0.kindLabel, $0.depthLabel, $0.timeLabel, $0.gasLabel] },
            includeNotCertifiedFooter: includesDecoStops
        )
    }

    private static func renderCard(
        title: String,
        modeLabel: String,
        generatedAt: Date,
        columnHeaders: [String],
        rowTexts: [[String]],
        includeNotCertifiedFooter: Bool
    ) throws -> UIImage {
        let size = CGSize(
            width: PlannerBriefingTransferSupport.cardPixelWidth,
            height: PlannerBriefingTransferSupport.cardPixelHeight
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let margin: CGFloat = 14
            var y: CGFloat = margin
            let titleFont = UIFont.systemFont(ofSize: 15, weight: .bold)
            let metaFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let headerFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
            let rowFont = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
            let footerFont = UIFont.systemFont(ofSize: 9, weight: .semibold)
            let cyan = UIColor(red: 0.0, green: 0.82, blue: 0.88, alpha: 1.0)

            func draw(_ text: String, font: UIFont, color: UIColor, x: CGFloat, width: CGFloat) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byTruncatingTail
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph,
                ]
                text.draw(
                    with: CGRect(x: x, y: y, width: width, height: 40),
                    options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                    attributes: attrs,
                    context: nil
                )
            }

            draw(title.uppercased(), font: titleFont, color: cyan, x: margin, width: size.width - margin * 2)
            y += 18
            draw(modeLabel, font: metaFont, color: .lightGray, x: margin, width: size.width - margin * 2)
            y += 12
            draw(Self.generatedAtLabel(generatedAt), font: metaFont, color: .lightGray, x: margin, width: size.width - margin * 2)
            y += 12
            draw(PlannerBriefingTransferSupport.referenceOnlyFooter, font: footerFont, color: .white, x: margin, width: size.width - margin * 2)
            y += 16

            let columnWidth = (size.width - margin * 2) / CGFloat(max(columnHeaders.count, 1))
            for (index, header) in columnHeaders.enumerated() {
                draw(header, font: headerFont, color: cyan, x: margin + CGFloat(index) * columnWidth, width: columnWidth - 2)
            }
            y += 14

            for row in rowTexts {
                for (index, value) in row.enumerated() {
                    draw(value, font: rowFont, color: .white, x: margin + CGFloat(index) * columnWidth, width: columnWidth - 2)
                }
                y += 13
            }

            y = size.height - margin - (includeNotCertifiedFooter ? 24 : 12)
            draw(PlannerBriefingTransferSupport.referenceOnlyFooter, font: footerFont, color: .white, x: margin, width: size.width - margin * 2)
            if includeNotCertifiedFooter {
                y += 11
                draw(PlannerBriefingTransferSupport.notCertifiedFooter, font: footerFont, color: .orange, x: margin, width: size.width - margin * 2)
            }
        }
    }
}
