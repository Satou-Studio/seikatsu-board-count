// Copy into the UNIT TEST file of an exported temporary checkout only.
// Never run on a physical device or an existing user's Simulator.
import XCTest
@testable import SeikatsuBoardCount

final class StorefrontSeedTests: XCTestCase {
    @MainActor
    func testSeedDedicatedSimulatorUsingProductionOperations() throws {
        #if targetEnvironment(simulator)
        guard ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == "Count-Storefront-20261006" else {
            throw XCTSkip("Dedicated screenshot Simulator required")
        }
        let store = CountStore()
        XCTAssertFalse(store.needsRecovery)
        guard !store.needsRecovery, store.records.isEmpty, store.items.count == 5 else {
            XCTFail("Not a fresh screenshot environment; do not overwrite")
            return
        }
        store.moveItems(from: IndexSet(integersIn: 1...2), to: 0)
        let brush = try XCTUnwrap(store.items.first { $0.title == "はみがき" })
        let clothes = try XCTUnwrap(store.items.first { $0.title == "ふくをきれた" })
        let days = CalendarHelper.recentDaysNewestFirst()
        let counts = [(2, 1), (1, 1), (2, 1), (1, 0), (2, 1), (1, 1), (1, 0)]
        for (offset, pair) in counts.enumerated() {
            for _ in 0..<pair.0 { store.increment(brush, on: days[offset]) }
            for _ in 0..<pair.1 { store.increment(clothes, on: days[offset]) }
            XCTAssertEqual(store.total(on: days[offset]), pair.0 + pair.1)
        }
        // Same operation as today's Undo button; restore the original synthetic count.
        store.increment(brush)
        store.decrement(brush)
        XCTAssertEqual(store.count(for: brush), 2)
        let reloaded = CountStore()
        XCTAssertFalse(reloaded.needsRecovery)
        XCTAssertEqual(reloaded.records, store.records)
        let data = try XCTUnwrap(UserDefaults.standard.data(forKey: "seikatsuboard-count-state-v1"))
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
        attachment.name = "synthetic-state"
        attachment.lifetime = .keepAlways
        add(attachment)
        #else
        throw XCTSkip("Simulator only")
        #endif
    }
}
