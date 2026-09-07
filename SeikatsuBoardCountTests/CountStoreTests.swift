import XCTest
@testable import SeikatsuBoardCount

@MainActor
final class CountStoreTests: XCTestCase {
    private let key = "seikatsuboard-count-state-v1"
    private var defaults: UserDefaults!
    private var suite: String!
    private var backupDirectory: URL!

    override func setUp() async throws {
        suite = "CountStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        backupDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(suite)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suite)
        if FileManager.default.fileExists(atPath: backupDirectory.path) {
            try FileManager.default.removeItem(at: backupDirectory)
        }
        defaults = nil
    }

    func testFirstLaunchSeedsOnlyOnce() {
        let first = CountStore(defaults: defaults)
        XCTAssertEqual(first.items.count, 5)
        XCTAssertEqual(CountStore(defaults: defaults).items, first.items)
    }

    func testEmptyStateSurvivesRestart() {
        let store = CountStore(defaults: defaults)
        store.deleteItems(at: IndexSet(store.items.indices))
        XCTAssertTrue(CountStore(defaults: defaults).items.isEmpty)
    }

    func testCorruptDataIsNotOverwritten() {
        let original = Data("broken record".utf8)
        defaults.set(original, forKey: key)
        _ = CountStore(defaults: defaults)
        XCTAssertEqual(defaults.data(forKey: key), original)
    }

    func testUnexpectedStoredTypeIsNotOverwritten() {
        defaults.set("unexpected format", forKey: key)
        _ = CountStore(defaults: defaults)
        XCTAssertEqual(defaults.string(forKey: key), "unexpected format")
    }

    // Literal fixture in the shipped 1.0 shape: no schemaVersion.
    private var legacy: Data {
        Data("""
        {"items":[{"id":"11111111-1111-1111-1111-111111111111","title":"はみがき","emoji":"🪥","sortOrder":0}],
         "records":[{"id":"22222222-2222-2222-2222-222222222222","itemID":"11111111-1111-1111-1111-111111111111","dayKey":"2026-07-25","count":3},
                    {"id":"33333333-3333-3333-3333-333333333333","itemID":"11111111-1111-1111-1111-111111111111","dayKey":"2026-07-27","count":2}]}
        """.utf8)
    }

    private func protectedStore() -> CountStore {
        let directory = backupDirectory!
        return CountStore(defaults: defaults) { original in
            try CountRecoveryBackup.preserve(original, in: directory)
        }
    }

    private func exerciseAllMutations(_ store: CountStore) {
        let stale = CountItem(title: "前の項目", emoji: "⭐️", sortOrder: 0)
        store.addItem(title: "新しい項目", emoji: "⭐️")
        store.increment(stale)
        store.decrement(stale)
        store.updateItem(stale, title: "変更", emoji: "🪥")
        // Invalid offsets would crash if the read-only guard were missing.
        store.deleteItems(at: IndexSet(integer: 0))
        store.moveItems(from: IndexSet(integer: 0), to: 1)
    }

    func testFailureBlocksEveryMutationAndSurvivesRepeatedRestarts() {
        let original = Data([0, 255, 13, 10])
        defaults.set(original, forKey: key)
        for _ in 0..<3 {
            let store = CountStore(defaults: UserDefaults(suiteName: suite)!)
            XCTAssertTrue(store.needsRecovery)
            exerciseAllMutations(store)
            store.retryLoading()
            XCTAssertTrue(store.items.isEmpty)
            XCTAssertTrue(store.records.isEmpty)
            XCTAssertTrue(store.needsRecovery)
            XCTAssertEqual(defaults.data(forKey: key), original)
        }
    }

    func testUnsupportedJSONIsPreservedAfterOperations() throws {
        var future = try XCTUnwrap(JSONSerialization.jsonObject(with: legacy) as? [String: Any])
        future["schemaVersion"] = 2
        var unknown = future
        unknown["schemaVersion"] = 1
        unknown["futureRecords"] = ["do not lose"]
        var nested = try XCTUnwrap(JSONSerialization.jsonObject(with: legacy) as? [String: Any])
        var nestedItems = try XCTUnwrap(nested["items"] as? [[String: Any]])
        nestedItems[0]["futureField"] = "do not lose"
        nested["items"] = nestedItems
        let examples: [Any] = [
            future, unknown, nested,
            ["items": [], "records": [], "schemaVersion": NSNull()],
            ["items": [], "records": [], "schemaVersion": "1"],
            ["items": []], ["records": []], ["items": "wrong", "records": []], []
        ]
        for example in examples {
            let original = try JSONSerialization.data(withJSONObject: example)
            defaults.set(original, forKey: key)
            let store = CountStore(defaults: defaults)
            XCTAssertTrue(store.needsRecovery)
            exerciseAllMutations(store)
            XCTAssertEqual(defaults.data(forKey: key), original)
            XCTAssertTrue(CountStore(defaults: defaults).needsRecovery)
        }
    }

    func testUnexpectedPropertyListTypesArePreserved() {
        let values: [Any] = ["wrong type", 42, true, ["key": "value"], ["one", "two"]]
        for value in values {
            defaults.set(value, forKey: key)
            let before = defaults.object(forKey: key) as? NSObject
            let store = CountStore(defaults: defaults)
            exerciseAllMutations(store)
            XCTAssertTrue(store.needsRecovery)
            XCTAssertEqual(defaults.object(forKey: key) as? NSObject, before)
        }
    }

    func testLegacyLoadIsReadOnlyAndKeepsIDsRecordsAndDayKeys() {
        defaults.set(legacy, forKey: key)
        let store = CountStore(defaults: defaults)
        XCTAssertFalse(store.needsRecovery)
        XCTAssertEqual(store.items.first?.id.uuidString, "11111111-1111-1111-1111-111111111111")
        XCTAssertEqual(store.records.map(\.dayKey), ["2026-07-25", "2026-07-27"])
        XCTAssertEqual(store.records.map(\.count), [3, 2])
        XCTAssertEqual(store.records.first?.id.uuidString, "22222222-2222-2222-2222-222222222222")
        XCTAssertEqual(defaults.data(forKey: key), legacy)
        let restarted = CountStore(defaults: defaults)
        XCTAssertEqual(restarted.items, store.items)
        XCTAssertEqual(restarted.records, store.records)
    }

    func testLegacyEmptyDataIsNotWrittenOrSeeded() {
        let original = Data(#"{"items":[],"records":[]}"#.utf8)
        defaults.set(original, forKey: key)
        let store = CountStore(defaults: defaults)
        XCTAssertFalse(store.needsRecovery)
        XCTAssertTrue(store.items.isEmpty)
        XCTAssertEqual(defaults.data(forKey: key), original)
    }

    func testNextEditAddsSchemaWithoutChangingExistingRecords() throws {
        defaults.set(legacy, forKey: key)
        let store = CountStore(defaults: defaults)
        let oldRecords = store.records
        let oldItems = store.items
        store.addItem(title: " おてつだい ", emoji: " ")
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(defaults.data(forKey: key))) as? [String: Any])
        XCTAssertEqual(root["schemaVersion"] as? Int, 1)
        let restarted = CountStore(defaults: defaults)
        XCTAssertFalse(restarted.needsRecovery)
        XCTAssertEqual(restarted.records, oldRecords)
        XCTAssertEqual(restarted.items.first, oldItems.first)
        XCTAssertEqual(restarted.items.last?.title, "おてつだい")
        XCTAssertEqual(restarted.items.last?.emoji, "⭐️")
    }

    func testRecordAddUndoAndRestartKeepUnrelatedHistory() throws {
        defaults.set(legacy, forKey: key)
        let store = CountStore(defaults: defaults)
        let item = try XCTUnwrap(store.items.first)
        let date = try XCTUnwrap(CalendarHelper.calendar.date(from: DateComponents(year: 2026, month: 7, day: 25, hour: 12)))
        let oldRecordID = store.records[0].id
        store.increment(item, on: date)
        XCTAssertEqual(store.count(for: item, on: date), 4)
        store.decrement(item, on: date)
        XCTAssertEqual(store.count(for: item, on: date), 3)
        let newDate = date.addingTimeInterval(86400)
        store.increment(item, on: newDate)
        XCTAssertEqual(store.count(for: item, on: newDate), 1)
        store.decrement(item, on: newDate)
        store.decrement(item, on: newDate)
        XCTAssertEqual(store.count(for: item, on: newDate), 0)
        let restarted = CountStore(defaults: defaults)
        XCTAssertEqual(restarted.records, store.records)
        XCTAssertEqual(restarted.records[0].id, oldRecordID)
        XCTAssertEqual(restarted.count(for: item.id, dayKey: "2026-07-27"), 2)
    }

    func testEditReorderDeleteAndEmptyRestart() throws {
        defaults.set(legacy, forKey: key)
        let store = CountStore(defaults: defaults)
        let item = try XCTUnwrap(store.items.first)
        store.addItem(title: "追加", emoji: "⭐️")
        store.updateItem(item, title: "変更", emoji: "🌟")
        store.moveItems(from: IndexSet(integer: 0), to: 2)
        XCTAssertEqual(store.sortedItems.last?.id, item.id)
        XCTAssertEqual(store.count(for: item.id, dayKey: "2026-07-25"), 3)
        store.deleteItems(at: IndexSet(integer: 1))
        XCTAssertTrue(store.records.isEmpty)
        store.deleteItems(at: IndexSet(integer: 0))
        let restarted = CountStore(defaults: defaults)
        XCTAssertTrue(restarted.items.isEmpty)
        XCTAssertTrue(restarted.records.isEmpty)
        XCTAssertFalse(restarted.needsRecovery)
        restarted.addItem(title: "再開", emoji: "🌟")
        XCTAssertEqual(CountStore(defaults: defaults).items.count, 1)
    }

    func testRetryDoesNotInitializeWhenOriginalDisappears() {
        defaults.set(Data("broken".utf8), forKey: key)
        let store = CountStore(defaults: defaults)
        defaults.removeObject(forKey: key)
        store.retryLoading()
        store.addItem(title: "追加", emoji: "🌟")
        XCTAssertTrue(store.needsRecovery)
        XCTAssertNil(defaults.object(forKey: key))
    }

    func testRetryCanReadValidDataWithoutOverwritingIt() {
        defaults.set(Data("broken".utf8), forKey: key)
        let store = CountStore(defaults: defaults)
        defaults.set(legacy, forKey: key)
        store.retryLoading()
        XCTAssertFalse(store.needsRecovery)
        XCTAssertEqual(store.records.count, 2)
        XCTAssertEqual(defaults.data(forKey: key), legacy)
    }

    func testStartOverBacksUpExactBytesBeforeReplacingAndStaysEmpty() throws {
        let original = Data([0, 255, 10, 13])
        defaults.set(original, forKey: key)
        let directory = backupDirectory!
        let store = CountStore(defaults: defaults) { value in
            XCTAssertEqual(self.defaults.data(forKey: self.key), original)
            return try CountRecoveryBackup.preserve(value, in: directory)
        }
        store.startOverPreservingOriginal()
        XCTAssertFalse(store.needsRecovery)
        XCTAssertTrue(CountStore(defaults: defaults).items.isEmpty)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let envelope = try XCTUnwrap(PropertyListSerialization.propertyList(from: Data(contentsOf: XCTUnwrap(files.first)), format: nil) as? [String: Any])
        XCTAssertEqual(envelope["originalValue"] as? Data, original)
        XCTAssertEqual(envelope["storageKey"] as? String, key)
        store.addItem(title: "新しい記録", emoji: "⭐️")
        XCTAssertEqual(CountStore(defaults: defaults).items.count, 1)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil), files)
    }

    func testBackupFailurePreventsResetAndLaterMutation() {
        struct BackupFailure: Error {}
        defaults.set(legacy.dropLast(), forKey: key)
        let before = defaults.data(forKey: key)
        let store = CountStore(defaults: defaults) { _ in throw BackupFailure() }
        store.startOverPreservingOriginal()
        XCTAssertTrue(store.recoveryBackupFailed)
        XCTAssertTrue(store.needsRecovery)
        exerciseAllMutations(store)
        XCTAssertEqual(defaults.data(forKey: key), before)
        XCTAssertTrue(CountStore(defaults: defaults).needsRecovery)
    }

    func testBackupWriteErrorPreventsReset() throws {
        try Data("not a directory".utf8).write(to: backupDirectory)
        defaults.set("unreadable", forKey: key)
        let store = protectedStore()
        store.startOverPreservingOriginal()
        XCTAssertTrue(store.recoveryBackupFailed)
        XCTAssertEqual(defaults.string(forKey: key), "unreadable")
    }

    func testRepeatedResetsNeverReplacePreviousBackups() throws {
        for original in ["first failure", "second failure"] {
            defaults.set(original, forKey: key)
            let store = protectedStore()
            store.startOverPreservingOriginal()
            XCTAssertFalse(store.needsRecovery)
        }
        let files = try FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 2)
        let values = try files.map {
            let plist = try XCTUnwrap(PropertyListSerialization.propertyList(from: Data(contentsOf: $0), format: nil) as? [String: Any])
            return try XCTUnwrap(plist["originalValue"] as? String)
        }
        XCTAssertEqual(Set(values), ["first failure", "second failure"])
    }

    func testResetCannotBeUsedForHealthyRecords() {
        defaults.set(legacy, forKey: key)
        let store = protectedStore()
        store.startOverPreservingOriginal()
        XCTAssertEqual(defaults.data(forKey: key), legacy)
        XCTAssertFalse(FileManager.default.fileExists(atPath: backupDirectory.path))
    }

    func testInvalidRecordRelationshipsAreProtected() throws {
        let fixtures = [
            String(decoding: legacy, as: UTF8.self).replacingOccurrences(of: #""count":3"#, with: #""count":-1"#),
            String(decoding: legacy, as: UTF8.self).replacingOccurrences(of: #""itemID":"11111111-1111-1111-1111-111111111111""#, with: #""itemID":"99999999-9999-9999-9999-999999999999""#)
        ]
        for fixture in fixtures {
            let original = Data(fixture.utf8)
            defaults.set(original, forKey: key)
            XCTAssertTrue(CountStore(defaults: defaults).needsRecovery)
            XCTAssertEqual(defaults.data(forKey: key), original)
        }
    }

    func testDuplicateIDsAndRecordKeysAreProtected() throws {
        let base = try XCTUnwrap(JSONSerialization.jsonObject(with: legacy) as? [String: Any])
        let items = try XCTUnwrap(base["items"] as? [[String: Any]])
        let records = try XCTUnwrap(base["records"] as? [[String: Any]])
        var duplicateItem = base
        duplicateItem["items"] = items + items
        var duplicateRecordID = base
        duplicateRecordID["records"] = records + [records[0]]
        var otherIDSameDay = records[0]
        otherIDSameDay["id"] = UUID().uuidString
        var duplicateDay = base
        duplicateDay["records"] = records + [otherIDSameDay]
        for example in [duplicateItem, duplicateRecordID, duplicateDay] {
            let original = try JSONSerialization.data(withJSONObject: example)
            defaults.set(original, forKey: key)
            XCTAssertTrue(CountStore(defaults: defaults).needsRecovery)
            XCTAssertEqual(defaults.data(forKey: key), original)
        }
    }

    func testIntegerLimitsDoNotCrashOrLoseHistory() throws {
        let original = Data(String(decoding: legacy, as: UTF8.self)
            .replacingOccurrences(of: #""count":3"#, with: #""count":"# + String(Int.max))
            .replacingOccurrences(of: #""sortOrder":0"#, with: #""sortOrder":"# + String(Int.max - 1)).utf8)
        defaults.set(original, forKey: key)
        let store = CountStore(defaults: defaults)
        XCTAssertFalse(store.needsRecovery)
        let item = try XCTUnwrap(store.items.first)
        let date = try XCTUnwrap(CalendarHelper.calendar.date(from: DateComponents(year: 2026, month: 7, day: 25, hour: 12)))
        store.increment(item, on: date)
        XCTAssertEqual(defaults.data(forKey: key), original)
        store.decrement(item, on: date)
        XCTAssertEqual(store.count(for: item, on: date), Int.max - 1)
        store.addItem(title: "追加", emoji: "⭐️")
        let restarted = CountStore(defaults: defaults)
        XCTAssertFalse(restarted.needsRecovery)
        XCTAssertEqual(restarted.items.count, 2)
        XCTAssertEqual(restarted.records, store.records)
    }

    func testDailyTotalOverflowIsProtected() throws {
        var root = try XCTUnwrap(JSONSerialization.jsonObject(with: legacy) as? [String: Any])
        var items = try XCTUnwrap(root["items"] as? [[String: Any]])
        var records = try XCTUnwrap(root["records"] as? [[String: Any]])
        var secondItem = items[0]
        secondItem["id"] = "99999999-9999-9999-9999-999999999999"
        items.append(secondItem)
        records[0]["count"] = Int.max
        records[1]["itemID"] = secondItem["id"]
        records[1]["dayKey"] = records[0]["dayKey"]
        root["items"] = items
        root["records"] = records
        let original = try JSONSerialization.data(withJSONObject: root)
        defaults.set(original, forKey: key)
        XCTAssertTrue(CountStore(defaults: defaults).needsRecovery)
        XCTAssertEqual(defaults.data(forKey: key), original)
    }
}
