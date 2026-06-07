import UIKit

/// Shared PDF page layout: white background, black text, footer disclaimer, page numbers.
final class PDFPageContext {
    private let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
    private let margin: CGFloat = 48
    private let footerHeight: CGFloat = 44
    private var pdfContext: UIGraphicsPDFRendererContext?
    private var y: CGFloat = 0
    private(set) var pageNumber = 0
    private var documentTitle = ""
    private var generatedDate = ""

    var contentWidth: CGFloat { pageRect.width - margin * 2 }

    func attach(_ context: UIGraphicsPDFRendererContext, title: String, generatedAt: Date) {
        pdfContext = context
        documentTitle = title
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        generatedDate = formatter.string(from: generatedAt)
        beginPage()
    }

    func beginPage() {
        pdfContext?.beginPage()
        pageNumber += 1
        y = margin
        UIColor.white.setFill()
        UIRectFill(pageRect)
        drawHeader()
    }

    func ensureSpace(_ height: CGFloat) {
        guard y + height > pageRect.height - margin - footerHeight else { return }
        drawFooter()
        beginPage()
    }

    func drawSectionTitle(_ text: String) {
        ensureSpace(28)
        let font = UIFont.boldSystemFont(ofSize: 14)
        draw(text, font: font, color: .black)
        y += 6
    }

    func drawLine(_ label: String, value: String) {
        ensureSpace(18)
        let labelFont = UIFont.systemFont(ofSize: 11, weight: .medium)
        let valueFont = UIFont.systemFont(ofSize: 11)
        let labelWidth = contentWidth * 0.42
        label.draw(
            in: CGRect(x: margin, y: y, width: labelWidth, height: 16),
            withAttributes: [.font: labelFont, .foregroundColor: UIColor.darkGray]
        )
        value.draw(
            in: CGRect(x: margin + labelWidth, y: y, width: contentWidth - labelWidth, height: 16),
            withAttributes: [.font: valueFont, .foregroundColor: UIColor.black]
        )
        y += 18
    }

    func drawParagraph(_ text: String, font: UIFont = .systemFont(ofSize: 11)) {
        let rect = CGRect(x: margin, y: y, width: contentWidth, height: .greatestFiniteMagnitude)
        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        ensureSpace(bounding.height + 8)
        (text as NSString).draw(
            in: CGRect(x: margin, y: y, width: contentWidth, height: bounding.height),
            withAttributes: [.font: font, .foregroundColor: UIColor.black]
        )
        y += bounding.height + 8
    }

    func drawChecklistRow(yesLabel: String, noLabel: String, itemText: String) {
        ensureSpace(20)
        let boxFont = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        let prefix = "[ ] \(yesLabel)    [ ] \(noLabel)    "
        let prefixWidth = (prefix as NSString).size(withAttributes: [.font: boxFont]).width
        prefix.draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: boxFont, .foregroundColor: UIColor.black]
        )
        let itemFont = UIFont.systemFont(ofSize: 11)
        (itemText as NSString).draw(
            in: CGRect(x: margin + prefixWidth, y: y, width: contentWidth - prefixWidth, height: 16),
            withAttributes: [.font: itemFont, .foregroundColor: UIColor.black]
        )
        y += 20
    }

    func drawSpacer(_ height: CGFloat = 12) {
        y += height
    }

    func finish(disclaimer: String) {
        drawFooter(disclaimer: disclaimer)
    }

    private func drawHeader() {
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let metaFont = UIFont.systemFont(ofSize: 10)
        documentTitle.draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: titleFont, .foregroundColor: UIColor.black]
        )
        y += 24
        "DIR Diving".draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: metaFont, .foregroundColor: UIColor.gray]
        )
        generatedDate.draw(
            at: CGPoint(x: pageRect.width - margin - 120, y: y),
            withAttributes: [.font: metaFont, .foregroundColor: UIColor.gray]
        )
        y += 20
        drawRule()
    }

    private func drawRule() {
        ensureSpace(4)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: pageRect.width - margin, y: y))
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        y += 10
    }

    private func drawFooter(disclaimer: String? = nil) {
        let footerY = pageRect.height - margin - footerHeight + 8
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: footerY - 6))
        path.addLine(to: CGPoint(x: pageRect.width - margin, y: footerY - 6))
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        let disclaimerFont = UIFont.systemFont(ofSize: 8)
        let pageFont = UIFont.systemFont(ofSize: 9)
        if let disclaimer {
            (disclaimer as NSString).draw(
                in: CGRect(x: margin, y: footerY, width: contentWidth - 60, height: 32),
                withAttributes: [.font: disclaimerFont, .foregroundColor: UIColor.gray]
            )
        }
        let pageText = "\(pageNumber)"
        (pageText as NSString).draw(
            at: CGPoint(x: pageRect.width - margin - 20, y: footerY + 10),
            withAttributes: [.font: pageFont, .foregroundColor: UIColor.gray]
        )
    }

    private func draw(_ text: String, font: UIFont, color: UIColor) {
        (text as NSString).draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: font, .foregroundColor: color]
        )
        y += font.lineHeight + 2
    }
}

enum PDFExportFilename {
    static func make(prefix: String, siteName: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        if let site = sanitized(siteName), !site.isEmpty {
            return "\(prefix)_\(date)_\(site).pdf"
        }
        return "\(prefix)_\(date).pdf"
    }

    static func sanitized(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let cleaned = trimmed
            .replacingOccurrences(of: " ", with: "_")
            .unicodeScalars
            .filter { allowed.contains($0) }
            .map { String($0) }
            .joined()
        return cleaned.isEmpty ? nil : String(cleaned.prefix(40))
    }

    static func write(data: Data, filename: String) throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("DIRDivingPDF", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }
}
