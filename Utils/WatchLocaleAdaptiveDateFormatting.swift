import Foundation

enum WatchLocaleAdaptiveDateFormatting {
    static func sessionDateTimeText(for date: Date, locale: Locale) -> String {
        date.formatted(.dateTime.day().month().year().hour().minute().locale(locale))
    }

    static func sessionDateTimeAccessibilityLabel(for date: Date, locale: Locale) -> String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide).year().hour().minute().locale(locale))
    }
}
