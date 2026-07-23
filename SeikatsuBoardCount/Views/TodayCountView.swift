import SwiftUI

struct TodayCountView: View {
    @EnvironmentObject private var store: CountStore
    @State private var showingAddItem = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        totalCard

                        ForEach(store.sortedItems) { item in
                            TodayCountCard(item: item)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("きょうのできた！")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("できたをふやす")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                CountItemEditorView(mode: .add)
            }
        }
    }

    private var totalCard: some View {
        Card {
            HStack(spacing: 16) {
                EmojiCircle(emoji: "🌈", size: 62)
                VStack(alignment: .leading, spacing: 4) {
                    Text("きょうのできたごうけい")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appText)
                    Text("\(store.todayTotal)かい")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appGreen)
                }
            }
        }
    }
}

private struct TodayCountCard: View {
    @EnvironmentObject private var store: CountStore
    let item: CountItem

    var body: some View {
        Card {
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    EmojiCircle(emoji: item.emoji)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appText)
                        Text("きょう \(store.count(for: item))かい")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appBlue)
                    }

                    Spacer()
                }

                HStack(alignment: .center, spacing: 12) {
                    PrimaryCountButton {
                        store.increment(item)
                    }

                    Button {
                        store.decrement(item)
                    } label: {
                        Text("-1")
                            .font(.title3.weight(.bold))
                            .frame(width: 64, height: 56)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .accessibilityLabel("\(item.title)をひとつへらす")
                }
            }
        }
    }
}
