import Foundation
import SwiftUI

@MainActor
final class CountStore: ObservableObject {
    @Published private(set) var items: [CountItem] = []
    @Published private(set) var records: [CountRecord] = []
    @Published private(set) var needsRecovery = false
    @Published private(set) var recoveryBackupFailed = false

    private let defaults: UserDefaults
    private let storageKey = "seikatsuboard-count-state-v1"
    private let preserveOriginal: (Any) throws -> URL

    init(
        defaults: UserDefaults = .standard,
        preserveOriginal: @escaping (Any) throws -> URL = CountRecoveryBackup.preserve
    ) {
        self.defaults = defaults
        self.preserveOriginal = preserveOriginal
        load(allowFirstLaunch: true)
    }

    var sortedItems: [CountItem] {
        items.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.title < rhs.title
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    func total(on date: Date = Date()) -> Int {
        let dayKey = CalendarHelper.dayKey(for: date)
        return records
            .filter { $0.dayKey == dayKey }
            .reduce(0) { $0 + $1.count }
    }

    func count(for item: CountItem, on date: Date = Date()) -> Int {
        count(for: item.id, dayKey: CalendarHelper.dayKey(for: date))
    }

    func count(for itemID: UUID, dayKey: String) -> Int {
        records.first { $0.itemID == itemID && $0.dayKey == dayKey }?.count ?? 0
    }

    func increment(_ item: CountItem, on date: Date = Date()) {
        updateCount(for: item.id, dayKey: CalendarHelper.dayKey(for: date), delta: 1)
    }

    func decrement(_ item: CountItem, on date: Date = Date()) {
        updateCount(for: item.id, dayKey: CalendarHelper.dayKey(for: date), delta: -1)
    }

    func addItem(title: String, emoji: String) {
        guard !needsRecovery else { return }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        // Normalize before exhausting the persisted sort-order range.
        if items.contains(where: { $0.sortOrder >= Int.max - 1 }) {
            normalizeSortOrder()
        }
        let nextOrder = (items.map(\.sortOrder).max() ?? -1) + 1
        items.append(CountItem(title: cleanTitle, emoji: cleanEmoji.isEmpty ? "⭐️" : cleanEmoji, sortOrder: nextOrder))
        save()
    }

    func updateItem(_ item: CountItem, title: String, emoji: String) {
        guard !needsRecovery else { return }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty, let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        items[index].title = cleanTitle
        items[index].emoji = cleanEmoji.isEmpty ? "⭐️" : cleanEmoji
        save()
    }

    func deleteItems(at offsets: IndexSet) {
        guard !needsRecovery else { return }
        let sorted = sortedItems
        let deletedIDs = offsets.map { sorted[$0].id }
        items.removeAll { deletedIDs.contains($0.id) }
        records.removeAll { deletedIDs.contains($0.itemID) }
        normalizeSortOrder()
        save()
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        guard !needsRecovery else { return }
        var sorted = sortedItems
        sorted.move(fromOffsets: source, toOffset: destination)
        saveOrder(sorted)
    }

    private func updateCount(for itemID: UUID, dayKey: String, delta: Int) {
        guard !needsRecovery, items.contains(where: { $0.id == itemID }) else { return }
        // Do not overflow even if a readable record is already at the integer limit.
        guard delta < 0 || total(forDayKey: dayKey) < Int.max else { return }
        if let index = records.firstIndex(where: { $0.itemID == itemID && $0.dayKey == dayKey }) {
            records[index].count = max(0, records[index].count + delta)
        } else if delta > 0 {
            records.append(CountRecord(itemID: itemID, dayKey: dayKey, count: delta))
        }
        save()
    }

    func retryLoading() {
        guard needsRecovery else { return }
        load(allowFirstLaunch: false)
    }

    /// Called only after the recovery screen's explicit confirmation.
    /// A verified, separate copy must exist before replacing the active value.
    func startOverPreservingOriginal() {
        guard needsRecovery, let original = defaults.object(forKey: storageKey) else { return }
        do {
            _ = try preserveOriginal(original)
            let empty = try JSONEncoder().encode(CountState(items: [], records: []))
            defaults.set(empty, forKey: storageKey)
            items = []
            records = []
            recoveryBackupFailed = false
            needsRecovery = false
        } catch {
            recoveryBackupFailed = true
        }
    }

    private func load(allowFirstLaunch: Bool) {
        recoveryBackupFailed = false
        guard let original = defaults.object(forKey: storageKey) else {
            // Retry after a failure is never treated as a first launch.
            if allowFirstLaunch {
                seedSampleItems()
                save()
            } else {
                needsRecovery = true
            }
            return
        }

        do {
            guard let data = original as? Data else { throw CountDataError.unsupported }
            let state = try CountState.read(data)
            items = state.items
            records = state.records
            needsRecovery = false
        } catch {
            needsRecovery = true
        }
    }

    private func save() {
        guard !needsRecovery else { return }
        let state = CountState(items: items, records: records)
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func total(forDayKey dayKey: String) -> Int {
        records.filter { $0.dayKey == dayKey }.reduce(0) { $0 + $1.count }
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
    var schemaVersion = 1
    var items: [CountItem]
    var records: [CountRecord]

    static func read(_ data: Data) throws -> CountState {
        // JSONDecoder ignores unknown fields. Reject them before saving so that a
        // future format (including nested fields) cannot be silently truncated.
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              Set(root.keys).isSubset(of: ["schemaVersion", "items", "records"]),
              let rawItems = root["items"] as? [[String: Any]],
              let rawRecords = root["records"] as? [[String: Any]],
              rawItems.allSatisfy({ Set($0.keys) == ["id", "title", "emoji", "sortOrder"] }),
              rawRecords.allSatisfy({ Set($0.keys) == ["id", "itemID", "dayKey", "count"] })
        else { throw CountDataError.unsupported }

        // Version 1.0 had no schemaVersion. Only that exact legacy shape is
        // accepted. Reading never writes; the next edit adds schemaVersion 1.
        let state: CountState
        if root["schemaVersion"] == nil {
            let legacy = try JSONDecoder().decode(LegacyState.self, from: data)
            state = CountState(items: legacy.items, records: legacy.records)
        } else {
            state = try JSONDecoder().decode(CountState.self, from: data)
            guard state.schemaVersion == 1 else { throw CountDataError.unsupported }
        }
        guard Set(state.items.map(\.id)).count == state.items.count,
              Set(state.records.map(\.id)).count == state.records.count,
              state.items.allSatisfy({ $0.sortOrder >= 0 && $0.sortOrder < Int.max })
        else { throw CountDataError.unsupported }
        let itemIDs = Set(state.items.map(\.id))
        var recordKeys = Set<String>()
        var totals: [String: Int] = [:]
        for record in state.records {
            guard itemIDs.contains(record.itemID), record.count >= 0,
                  recordKeys.insert(record.itemID.uuidString + "/" + record.dayKey).inserted
            else { throw CountDataError.unsupported }
            let (total, overflow) = (totals[record.dayKey] ?? 0).addingReportingOverflow(record.count)
            guard !overflow else { throw CountDataError.unsupported }
            totals[record.dayKey] = total
        }
        return state
    }

    private struct LegacyState: Decodable {
        var items: [CountItem]
        var records: [CountRecord]
    }
}

private enum CountDataError: Error {
    case unsupported
    case backupVerificationFailed
}

enum CountRecoveryBackup {
    static func preserve(_ original: Any) throws -> URL {
        let support = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )
        return try preserve(original, in: support.appendingPathComponent("CountRecovery", isDirectory: true))
    }

    static func preserve(_ original: Any, in directory: URL) throws -> URL {
        // Property lists preserve both Data bytes and unexpected UserDefaults
        // types. Each attempt gets a new file; earlier copies are never replaced.
        let envelope: [String: Any] = [
            "storageKey": "seikatsuboard-count-state-v1",
            "originalValue": original
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: envelope, format: .binary, options: 0)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("plist")
        try data.write(to: url, options: .atomic)
        guard try Data(contentsOf: url) == data else { throw CountDataError.backupVerificationFailed }
        return url
    }
}
