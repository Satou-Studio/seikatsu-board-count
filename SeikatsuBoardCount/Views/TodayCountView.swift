import SwiftUI
import UniformTypeIdentifiers

struct TodayCountView: View {
    @EnvironmentObject private var store: CountStore
    @State private var showingAddItem = false
    @State private var draggedItem: CountItem?
    @State private var dropTargetItemID: UUID?
    @State private var dragResetID = UUID()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 10) {
                        totalCard

                        ForEach(store.sortedItems) { item in
                            TodayCountCard(item: item, draggedItem: $draggedItem)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            Color.appOrange,
                                            lineWidth: draggedItem?.id == item.id ? 3 : 0
                                        )
                                }
                                .opacity(draggedItem?.id == item.id ? 0.82 : 1)
                                .scaleEffect(cardScale(for: item))
                                .zIndex(draggedItem?.id == item.id ? 1 : 0)
                                .onDrop(
                                    of: [UTType.text],
                                    delegate: TodayCardDropDelegate(
                                        targetItem: item,
                                        draggedItem: $draggedItem,
                                        dropTargetItemID: $dropTargetItemID,
                                        store: store,
                                        onDragActivity: scheduleDragStateReset,
                                        onDropFinished: clearDragState
                                    )
                                )
                        }
                    }
                    .animation(
                        .spring(response: 0.48, dampingFraction: 0.72),
                        value: store.sortedItems
                    )
                    .animation(.easeInOut(duration: 0.18), value: draggedItem?.id)
                    .animation(.easeInOut(duration: 0.18), value: dropTargetItemID)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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

    private func cardScale(for item: CountItem) -> CGFloat {
        if draggedItem?.id == item.id {
            return 0.94
        }
        if dropTargetItemID == item.id {
            return 0.97
        }
        return 1
    }

    private func scheduleDragStateReset() {
        let resetID = UUID()
        dragResetID = resetID

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard dragResetID == resetID else { return }
            clearDragState()
        }
    }

    private func clearDragState() {
        dragResetID = UUID()
        withAnimation(.easeOut(duration: 0.16)) {
            draggedItem = nil
            dropTargetItemID = nil
        }
    }

    private var totalCard: some View {
        HStack(spacing: 12) {
            EmojiCircle(emoji: "🌈", size: 46)
            VStack(alignment: .leading, spacing: 0) {
                Text("きょうのできたごうけい")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appText)
                Text("\(store.todayTotal)かい")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appGreen)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
    }
}

private struct TodayCountCard: View {
    @EnvironmentObject private var store: CountStore
    let item: CountItem
    @Binding var draggedItem: CountItem?

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                EmojiCircle(emoji: item.emoji, size: 40)

                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appText)
                    Text("きょう \(store.count(for: item))かい")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appBlue)
                }

                Spacer()

                Image(systemName: "line.3.horizontal")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
                    .onDrag {
                        draggedItem = item
                        return NSItemProvider(object: item.id.uuidString as NSString)
                    } preview: {
                        DragPreview(item: item)
                    }
                    .accessibilityLabel("\(item.title)をならびかえる")
            }

            HStack(alignment: .center, spacing: 8) {
                PrimaryCountButton {
                    store.increment(item)
                }

                Button {
                    store.decrement(item)
                } label: {
                    Text("もどす")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 68, height: 48)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(item.title)をひとつもどす")
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
    }
}

private struct TodayCardDropDelegate: DropDelegate {
    let targetItem: CountItem
    @Binding var draggedItem: CountItem?
    @Binding var dropTargetItemID: UUID?
    let store: CountStore
    let onDragActivity: () -> Void
    let onDropFinished: () -> Void

    func dropEntered(info: DropInfo) {
        guard
            let draggedItem,
            draggedItem.id != targetItem.id,
            let sourceIndex = store.sortedItems.firstIndex(where: { $0.id == draggedItem.id }),
            let targetIndex = store.sortedItems.firstIndex(where: { $0.id == targetItem.id })
        else {
            return
        }

        dropTargetItemID = targetItem.id
        onDragActivity()

        withAnimation(.spring(response: 0.48, dampingFraction: 0.72)) {
            store.moveItems(
                from: IndexSet(integer: sourceIndex),
                to: targetIndex > sourceIndex ? targetIndex + 1 : targetIndex
            )
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        onDragActivity()
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        onDropFinished()
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
