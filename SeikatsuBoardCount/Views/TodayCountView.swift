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
                            ReorderableTodayCountCard(item: item)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("きょうのできた！")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.appText)
                        Text(CalendarHelper.todayDisplayLabel())
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                }

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

private struct ReorderableTodayCountCard: View {
    @EnvironmentObject private var store: CountStore
    @State private var cardHeight: CGFloat = 1
    @State private var isDropTarget = false
    let item: CountItem

    var body: some View {
        TodayCountCard(item: item)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            cardHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size.height) { _, newHeight in
                            cardHeight = newHeight
                        }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.appOrange, lineWidth: isDropTarget ? 3 : 0)
                    .padding(1)
            }
            .draggable(item.id.uuidString) {
                DragPreview(item: item)
            }
            .dropDestination(for: String.self) { droppedIDs, location in
                guard
                    let droppedID = droppedIDs.first,
                    let movingID = UUID(uuidString: droppedID)
                else {
                    return false
                }

                store.moveItem(
                    id: movingID,
                    relativeTo: item.id,
                    placeAfter: location.y > cardHeight / 2
                )
                return true
            } isTargeted: { isTargeted in
                isDropTarget = isTargeted
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

                    Image(systemName: "line.3.horizontal")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }

                HStack(alignment: .center, spacing: 12) {
                    PrimaryCountButton {
                        store.increment(item)
                    }

                    Button {
                        store.decrement(item)
                    } label: {
                        Text("もどす")
                            .font(.headline.weight(.bold))
                            .frame(width: 84, height: 56)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .accessibilityLabel("\(item.title)をひとつもどす")
                }
            }
        }
    }
}

private struct DragPreview: View {
    let item: CountItem

    var body: some View {
        HStack(spacing: 12) {
            Text(item.emoji)
                .font(.system(size: 30))
            Text(item.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appText)
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
    }
}
