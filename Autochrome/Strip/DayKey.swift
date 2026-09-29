import Foundation

/// Day boundary for the strip. A mark stores YYYYMMDD from the start of the local day.
enum DayKey {
    static func make(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    /// Keeper-facing day. Never a grouped integer of the YYYYMMDD key.
    static func moment(_ daykey: Int) -> String {
        var parts = DateComponents()
        parts.year = daykey / 10_000
        parts.month = (daykey / 100) % 100
        parts.day = daykey % 100
        guard let date = Calendar.current.date(from: parts) else {
            return "Saved moment"
        }
        return Self.momentFormatter.string(from: date)
    }

    private static let momentFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        return formatter
    }()
}
