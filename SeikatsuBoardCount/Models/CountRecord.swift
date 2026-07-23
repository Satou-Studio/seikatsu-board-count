import Foundation

struct CountRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let itemID: UUID
    let dayKey: String
    var count: Int

    init(id: UUID = UUID(), itemID: UUID, dayKey: String, count: Int) {
        self.id = id
        self.itemID = itemID
        self.dayKey = dayKey
        self.count = count
    }
}
