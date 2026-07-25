import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: CountStore
    private var days: [Date] {
        CalendarHelper.recentDaysNewestFirst()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(days, id: \.self) { day in
                            HistoryDayCard(day: day)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("きろく")
        }
    }
}

private struct HistoryDayCard: View {
    @EnvironmentObject private var store: CountStore
    let day: Date
    private let maxCount = 5

    private var dayKey: String {
        CalendarHelper.dayKey(for: day)
    }

    private var completedItems: [CountItem] {
        store.sortedItems.filter {
            store.count(for: $0.id, dayKey: dayKey) > 0
        }
    }

    private var total: Int {
        completedItems.reduce(0) {
            $0 + store.count(for: $1.id, dayKey: dayKey)
        }
    }

    private var isToday: Bool {
        dayKey == CalendarHelper.dayKey()
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(
                            "\(CalendarHelper.weekdayLabel(for: day)) \(CalendarHelper.shortDateLabel(for: day))"
                        )
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appText)

                        if isToday {
                            Text("きょう")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color.appOrange)
                        }

                        Spacer()
                    }

                    Text("ぜんぶで \(total)かい")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appGreen)
                }

                Divider()

                if completedItems.isEmpty {
                    Text("まだ きろくは ないよ")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                } else {
                    VStack(spacing: 14) {
                        ForEach(completedItems) { item in
                            let count = store.count(for: item.id, dayKey: dayKey)

                            VStack(spacing: 7) {
                                HStack(spacing: 10) {
                                    EmojiCircle(emoji: item.emoji, size: 40)

                                    Text(item.title)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(Color.appText)

                                    Spacer()

                                    Text("\(count)かい")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.appGreen)
                                }

                                HStack(spacing: 10) {
                                    Color.clear
                                        .frame(width: 40, height: 1)

                                    CountBar(count: count, maxCount: maxCount)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct CountBar: View {
    let count: Int
    let maxCount: Int

    private var progress: Double {
        guard maxCount > 0 else { return 0 }
        return min(Double(max(count, 0)) / Double(maxCount), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.appGreen.opacity(0.16))

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.appGreen)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 16)
        .accessibilityLabel("\(count)かい")
    }
}
