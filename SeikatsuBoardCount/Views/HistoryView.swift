import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: CountStore
    private var days: [Date] {
        CalendarHelper.recentSevenDays()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(store.sortedItems) { item in
                            HistoryItemCard(item: item, days: days)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("きろく")
        }
    }
}

private struct HistoryItemCard: View {
    @EnvironmentObject private var store: CountStore
    let item: CountItem
    let days: [Date]
    private let maxCount = 5

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    EmojiCircle(emoji: item.emoji, size: 48)
                    Text(item.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appText)
                    Spacer()
                }

                VStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        let key = CalendarHelper.dayKey(for: day)
                        let count = store.count(for: item.id, dayKey: key)
                        HStack {
                            Text(CalendarHelper.weekdayLabel(for: day))
                                .font(.title3.weight(.bold))
                                .frame(width: 36, alignment: .leading)
                            CountBar(count: count, maxCount: maxCount)
                            Text("\(count)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.appGreen)
                                .frame(width: 42, alignment: .trailing)
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
