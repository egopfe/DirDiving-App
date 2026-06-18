import Foundation
import UIKit

enum IOSSnorkelingSessionExportError: Error, Equatable {
    case privacyConfirmationRequired
    case emptyDataset
    case writeFailed
    case gpxUnavailable
}

@MainActor
enum IOSSnorkelingSessionExportService {
    static func export(
        session: SnorkelingSession,
        format: SnorkelingExportFormat,
        options: SnorkelingExportPrivacyOptions
    ) throws -> URL {
        if SnorkelingExportPrivacyPolicy.requiresLocationConfirmation(for: session),
           (format == .gpx || options.locationPrecision != .removed),
           !SnorkelingExportPrivacyPolicy.canExportLocation(options: options, session: session) {
            throw IOSSnorkelingSessionExportError.privacyConfirmationRequired
        }

        switch format {
        case .pdf:
            return try writePDF(session: session, options: options)
        case .csv:
            guard let document = SnorkelingSessionExportEngine.buildCSV(for: session, options: options) else {
                throw IOSSnorkelingSessionExportError.emptyDataset
            }
            return try write(document: document)
        case .json:
            let document = try SnorkelingSessionExportEngine.buildJSON(for: session, options: options)
            return try write(document: document)
        case .gpx:
            guard let document = SnorkelingSessionExportEngine.buildGPX(for: session, options: options) else {
                throw IOSSnorkelingSessionExportError.gpxUnavailable
            }
            return try write(document: document)
        case .chartImage:
            return try writeChartSummary(session: session)
        }
    }

    private static func writePDF(session: SnorkelingSession, options: SnorkelingExportPrivacyOptions) throws -> URL {
        let lines = SnorkelingSessionExportEngine.buildPDFLines(for: session, options: options)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { context in
            let page = PDFPageContext()
            page.attach(context, title: "Snorkeling Session", generatedAt: Date())
            page.drawSectionTitle("Session summary")
            for line in lines {
                if line.hasPrefix("DIR Diving") {
                    page.drawParagraph(line, font: .boldSystemFont(ofSize: 16))
                } else {
                    page.drawParagraph(line)
                }
            }
            page.finish(disclaimer: "Personal logbook export only.")
        }
        let filename = SnorkelingExportFileNaming.filename(for: session, format: .pdf)
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    private static func writeChartSummary(session: SnorkelingSession) throws -> URL {
        let summary = SnorkelingSessionExportEngine.buildChartSummaryText(for: session)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 800, height: 480))
        let data = renderer.pdfData { context in
            context.beginPage()
            let rect = CGRect(x: 40, y: 40, width: 720, height: 400)
            UIColor(red: 0.02, green: 0.04, blue: 0.06, alpha: 1).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 800, height: 480))
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left
            (summary as NSString).draw(
                in: rect,
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraph,
                ]
            )
        }
        let filename = SnorkelingExportFileNaming.filename(for: session, format: .chartImage)
            .replacingOccurrences(of: ".png", with: ".pdf")
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    private static func write(document: SnorkelingExportDocument) throws -> URL {
        let directory = try PDFExportFilename.protectedExportDirectory()
        let url = directory.appendingPathComponent(document.filename)
        try document.data.write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }
}
