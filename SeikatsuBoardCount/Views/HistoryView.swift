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
            .navigationTitle("7にちのきろく")
        }
    }
}

private struct HistoryItemCard: View {
    @EnvironmentObject private var store: CountStore
    let item: CountItem
    let days: [Date]

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
                        HStack {
                            Text(CalendarHelper.weekdayLabel(for: day))
                                .font(.title3.weight(.bold))
                                .frame(width: 36, alignment: .leading)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.appGreen.opacity(0.16))
                                .frame(height: 12)
                            Text("\(store.count(for: item.id, dayKey: key))")
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
