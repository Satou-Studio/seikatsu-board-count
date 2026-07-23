import SwiftUI

struct TodayCountView: View {
    @EnvironmentObject private var store: CountStore
    @State private var showingAddItem = false
    @State private var draggedItem: CountItem?
    @State private var dragLocation = CGPoint.zero
    @State private var itemFrames: [UUID: CGRect] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 10) {
                        totalCard

                        ForEach(store.sortedItems) { item in
                            TodayCountCard(
                                item: item,
                                onDragChanged: { value in
                                    updateDrag(for: item, value: value)
                                },
                                onDragEnded: endDrag
                            )
                            .background {
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: ItemFramePreferenceKey.self,
                                        value: [
                                            item.id: proxy.frame(in: .named("todayCountList"))
                                        ]
                                    )
                                }
                            }
                            .opacity(draggedItem?.id == item.id ? 0 : 1)
                        }
                    }
                    .animation(
                        .spring(response: 0.48, dampingFraction: 0.72),
                        value: store.sortedItems
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                if let draggedItem {
                    DragPreview(item: draggedItem)
                        .position(dragLocation)
                        .allowsHitTesting(false)
                        .zIndex(10)
                }
            }
            .coordinateSpace(name: "todayCountList")
            .onPreferenceChange(ItemFramePreferenceKey.self) { frames in
                itemFrames = frames
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

    private func updateDrag(for item: CountItem, value: DragGesture.Value) {
        if draggedItem?.id != item.id {
            draggedItem = item
        }
        dragLocation = value.location

        let sortedItems = store.sortedItems
        guard let sourceIndex = sortedItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        let candidates = sortedItems.filter { $0.id != item.id }
        guard let targetItem = candidates.min(by: { lhs, rhs in
            let lhsDistance = abs((itemFrames[lhs.id]?.midY ?? .greatestFiniteMagnitude) - value.location.y)
            let rhsDistance = abs((itemFrames[rhs.id]?.midY ?? .greatestFiniteMagnitude) - value.location.y)
            return lhsDistance < rhsDistance
        }),
        let targetIndex = sortedItems.firstIndex(where: { $0.id == targetItem.id }),
        let targetFrame = itemFrames[targetItem.id]
        else {
            return
        }

        if sourceIndex < targetIndex, value.location.y > targetFrame.midY {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.72)) {
                store.moveItems(
                    from: IndexSet(integer: sourceIndex),
                    to: targetIndex + 1
                )
            }
        } else if sourceIndex > targetIndex, value.location.y < targetFrame.midY {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.72)) {
                store.moveItems(
                    from: IndexSet(integer: sourceIndex),
                    to: targetIndex
                )
            }
        }
    }

    private func endDrag() {
        withAnimation(.easeOut(duration: 0.16)) {
            draggedItem = nil
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
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: () -> Void

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
                    .gesture(reorderGesture)
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

    private var reorderGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25, maximumDistance: 12)
            .sequenced(
                before: DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .named("todayCountList")
                )
            )
            .onChanged { value in
                if case .second(true, let dragValue?) = value {
                    onDragChanged(dragValue)
                }
            }
            .onEnded { _ in
                onDragEnded()
            }
    }
}

private struct ItemFramePreferenceKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]

    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in
            newValue
        })
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
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOrange, lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
    }
}
