import Foundation

/// Canonical product brand display — not translated; EN/IT catalogs map to identical value.
enum DIRBrandPresentation {
    static var displayName: String {
        String(localized: String.LocalizationValue("brand.name"))
    }
}
