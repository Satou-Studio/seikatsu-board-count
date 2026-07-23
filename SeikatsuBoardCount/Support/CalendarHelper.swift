import Foundation

enum CalendarHelper {
    static let calendar = Calendar(identifier: .gregorian)

    static func dayKey(for date: Date = Date()) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func recentDaysInWeekdayOrder(from date: Date = Date()) -> [Date] {
        let today = calendar.startOfDay(for: date)
        let todayWeekday = calendar.component(.weekday, from: today)

        return (1...7).compactMap { weekday in
            let daysAgo = (todayWeekday - weekday + 7) % 7
            return calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }
    }

    static func weekdayLabel(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let labels = ["日", "月", "火", "水", "木", "金", "土"]
        return labels[max(0, min(labels.count - 1, weekday - 1))]
    }

    static func shortDateLabel(for date: Date) -> String {
        let components = calendar.dateComponents([.month, .day], from: date)
        return "\(components.month ?? 0)/\(components.day ?? 0)"
    }

    static func todayDisplayLabel(from date: Date = Date()) -> String {
        let components = calendar.dateComponents([.month, .day], from: date)
        return "\(components.month ?? 0)月\(components.day ?? 0)日（\(weekdayLabel(for: date))）"
    }
}
