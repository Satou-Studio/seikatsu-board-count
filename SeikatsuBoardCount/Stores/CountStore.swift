import Foundation

@MainActor
final class CountStore: ObservableObject {
    @Published private(set) var items: [CountItem] = []
    @Published private(set) var records: [CountRecord] = []

    private let defaults: UserDefaults
    private let storageKey = "seikatsuboard-count-state-v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    var sortedItems: [CountItem] {
        items.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.title < rhs.title
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    var todayTotal: Int {
        let today = CalendarHelper.dayKey()
        return records
            .filter { $0.dayKey == today }
            .reduce(0) { $0 + $1.count }
    }

    func count(for item: CountItem, on date: Date = Date()) -> Int {
        count(for: item.id, dayKey: CalendarHelper.dayKey(for: date))
    }

    func count(for itemID: UUID, dayKey: String) -> Int {
        records.first { $0.itemID == itemID && $0.dayKey == dayKey }?.count ?? 0
    }

    func increment(_ item: CountItem) {
        updateCount(for: item.id, dayKey: CalendarHelper.dayKey(), delta: 1)
    }

    func decrement(_ item: CountItem) {
        updateCount(for: item.id, dayKey: CalendarHelper.dayKey(), delta: -1)
    }

    func addItem(title: String, emoji: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        let nextOrder = (items.map(\.sortOrder).max() ?? -1) + 1
        items.append(CountItem(title: cleanTitle, emoji: cleanEmoji.isEmpty ? "⭐️" : cleanEmoji, sortOrder: nextOrder))
        save()
    }

    func updateItem(_ item: CountItem, title: String, emoji: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty, let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        items[index].title = cleanTitle
        items[index].emoji = cleanEmoji.isEmpty ? "⭐️" : cleanEmoji
        save()
    }

    func deleteItems(at offsets: IndexSet) {
        let sorted = sortedItems
        let deletedIDs = offsets.map { sorted[$0].id }
        items.removeAll { deletedIDs.contains($0.id) }
        records.removeAll { deletedIDs.contains($0.itemID) }
        normalizeSortOrder()
        save()
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        var sorted = sortedItems
        sorted.move(fromOffsets: source, toOffset: destination)
        saveOrder(sorted)
    }

    func moveItem(id movingID: UUID, relativeTo targetID: UUID, placeAfter: Bool) {
        guard movingID != targetID else { return }

        var sorted = sortedItems
        guard
            let sourceIndex = sorted.firstIndex(where: { $0.id == movingID }),
            sorted.contains(where: { $0.id == targetID })
        else {
            return
        }

        let movingItem = sorted.remove(at: sourceIndex)
        guard let targetIndex = sorted.firstIndex(where: { $0.id == targetID }) else { return }
        let destination = placeAfter ? targetIndex + 1 : targetIndex
        sorted.insert(movingItem, at: destination)
        saveOrder(sorted)
    }

    private func updateCount(for itemID: UUID, dayKey: String, delta: Int) {
        if let index = records.firstIndex(where: { $0.itemID == itemID && $0.dayKey == dayKey }) {
            records[index].count = max(0, records[index].count + delta)
        } else if delta > 0 {
            records.append(CountRecord(itemID: itemID, dayKey: dayKey, count: delta))
        }
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            seedSampleItems()
            save()
            return
        }

        do {
            let state = try JSONDecoder().decode(CountState.self, from: data)
            items = state.items
            records = state.records
            if items.isEmpty {
                seedSampleItems()
                save()
            }
        } catch {
            seedSampleItems()
            save()
        }
    }

    private func save() {
        let state = CountState(items: items, records: records)
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func seedSampleItems() {
        items = [
            CountItem(title: "トイレ", emoji: "🚽", sortOrder: 0),
            CountItem(title: "はみがき", emoji: "🪥", sortOrder: 1),
            CountItem(title: "ふくをきれた", emoji: "👕", sortOrder: 2),
            CountItem(title: "ごはん", emoji: "🍚", sortOrder: 3),
            CountItem(title: "おてつだい", emoji: "⭐️", sortOrder: 4)
        ]
        records = []
    }

    private func normalizeSortOrder() {
        let sorted = sortedItems
        for (index, item) in sorted.enumerated() {
            if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
                items[itemIndex].sortOrder = index
            }
        }
    }

    private func saveOrder(_ sortedItems: [CountItem]) {
        var reorderedItems = sortedItems
        for index in reorderedItems.indices {
            reorderedItems[index].sortOrder = index
        }
        items = reorderedItems
        save()
    }
}

private struct CountState: Codable {
    var items: [CountItem]
    var records: [CountRecord]
}
