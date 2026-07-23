import Foundation

enum CalendarHelper {
    static let calendar = Calendar(identifier: .gregorian)

    static func dayKey(for date: Date = Date()) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func recentSevenDays(from date: Date = Date()) -> [Date] {
        (0..<7).reversed().compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: date))
        }
    }

    static func weekdayLabel(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let labels = ["日", "月", "火", "水", "木", "金", "土"]
        return labels[max(0, min(labels.count - 1, weekday - 1))]
    }

    static func todayDisplayLabel(from date: Date = Date()) -> String {
        let components = calendar.dateComponents([.month, .day], from: date)
        return "\(components.month ?? 0)月\(components.day ?? 0)日（\(weekdayLabel(for: date))）"
    }
}
