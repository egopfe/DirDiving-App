import Foundation
import UIKit

enum IOSApneaSessionExportError: Error, Equatable {
    case privacyConfirmationRequired
    case emptyDataset
    case writeFailed
    case gpxUnavailable
}

@MainActor
enum IOSApneaSessionExportService {
    static func export(
        session: ApneaSession,
        format: ApneaExportFormat,
        options: ApneaExportPrivacyOptions
    ) throws -> URL {
        if ApneaExportPrivacyPolicy.requiresLocationConfirmation(for: session),
           (format == .gpx || options.includeSurfaceGPS),
           !ApneaExportPrivacyPolicy.canExportLocation(options: options, session: session) {
            throw IOSApneaSessionExportError.privacyConfirmationRequired
        }

        switch format {
        case .pdf:
            return try writePDF(session: session, options: options)
        case .csv:
            guard let document = ApneaSessionExportEngine.buildCSV(for: session, options: options) else {
                throw IOSApneaSessionExportError.emptyDataset
            }
            return try write(document: document)
        case .json:
            let document = try ApneaSessionExportEngine.buildJSON(for: session, options: options)
            return try write(document: document)
        case .gpx:
            guard let document = ApneaSessionExportEngine.buildGPX(for: session, options: options) else {
                throw IOSApneaSessionExportError.gpxUnavailable
            }
            return try write(document: document)
        case .chartImage:
            return try writeChartSummary(session: session)
        }
    }

    private static func writePDF(session: ApneaSession, options: ApneaExportPrivacyOptions) throws -> URL {
        let lines = ApneaSessionExportEngine.buildPDFLines(for: session, options: options)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { context in
            let page = PDFPageContext()
            page.attach(context, title: "Apnea Session", generatedAt: Date())
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
        let filename = ApneaExportFileNaming.filename(for: session, format: .pdf)
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    private static func writeChartSummary(session: ApneaSession) throws -> URL {
        let summary = ApneaSessionExportEngine.buildChartSummaryText(for: session)
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
        // Store chart share artifact as PDF summary for reliability; filename uses chartImage slot.
        let filename = ApneaExportFileNaming.filename(for: session, format: .chartImage)
            .replacingOccurrences(of: ".png", with: ".pdf")
        return try PDFExportFilename.write(data: data, filename: filename)
    }

    private static func write(document: ApneaExportDocument) throws -> URL {
        let directory = try PDFExportFilename.protectedExportDirectory()
        let url = directory.appendingPathComponent(document.filename)
        try document.data.write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }
}
