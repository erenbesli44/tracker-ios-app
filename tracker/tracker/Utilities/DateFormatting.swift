import Foundation

enum DateFormatting {
    private static let isoParser: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoParserNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    // Fallback for no-timezone format with fractional seconds: "2026-05-02T09:13:40.310030"
    private static let isoParserNoTZWithFraction: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    // Fallback for no-timezone format: "2026-04-03T00:00:00"
    private static let isoParserNoTZ: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    // Fallback for date-only format: "2026-04-03"
    private static let isoParserDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let shortDateSameYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale.current
        return formatter
    }()

    private static let shortDateOtherYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale.current
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    static func parse(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        return isoParser.date(from: dateString)
            ?? isoParserNoFraction.date(from: dateString)
            ?? isoParserNoTZWithFraction.date(from: dateString)
            ?? isoParserNoTZ.date(from: dateString)
            ?? isoParserDateOnly.date(from: dateString)
    }

    static func displayDate(_ dateString: String?) -> String? {
        guard let date = parse(dateString) else { return nil }
        return displayFormatter.string(from: date)
    }

    // "Apr 16" (same year) or "Apr 16, 2025" (different year)
    static func shortDate(_ dateString: String?) -> String? {
        guard let date = parse(dateString) else { return nil }
        let sameYear = Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year)
        return sameYear
            ? shortDateSameYearFormatter.string(from: date)
            : shortDateOtherYearFormatter.string(from: date)
    }

    static func relativeDate(_ dateString: String?) -> String? {
        guard let date = parse(dateString) else { return nil }
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    static func formatDuration(_ seconds: Int?) -> String? {
        guard let seconds, seconds > 0 else { return nil }
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}
