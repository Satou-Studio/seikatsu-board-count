import SwiftUI
import UniformTypeIdentifiers

struct TodayCountView: View {
    @EnvironmentObject private var store: CountStore
    @State private var showingAddItem = false
    @State private var draggedItem: CountItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        totalCard

                        ForEach(store.sortedItems) { item in
                            TodayCountCard(item: item)
                                .opacity(draggedItem?.id == item.id ? 0.72 : 1)
                                .scaleEffect(draggedItem?.id == item.id ? 1.02 : 1)
                                .onDrag {
                                    draggedItem = item
                                    return NSItemProvider(object: item.id.uuidString as NSString)
                                } preview: {
                                    DragPreview(item: item)
                                }
                                .onDrop(
                                    of: [UTType.text],
                                    delegate: TodayCardDropDelegate(
                                        targetItem: item,
                                        draggedItem: $draggedItem,
                                        store: store
                                    )
                                )
                        }
                    }
                    .animation(.smooth(duration: 0.24), value: store.sortedItems)
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

private struct TodayCardDropDelegate: DropDelegate {
    let targetItem: CountItem
    @Binding var draggedItem: CountItem?
    let store: CountStore

    func dropEntered(info: DropInfo) {
        guard
            let draggedItem,
            draggedItem.id != targetItem.id,
            let sourceIndex = store.sortedItems.firstIndex(where: { $0.id == draggedItem.id }),
            let targetIndex = store.sortedItems.firstIndex(where: { $0.id == targetItem.id })
        else {
            return
        }

        withAnimation(.smooth(duration: 0.24)) {
            store.moveItems(
                from: IndexSet(integer: sourceIndex),
                to: targetIndex > sourceIndex ? targetIndex + 1 : targetIndex
            )
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
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
