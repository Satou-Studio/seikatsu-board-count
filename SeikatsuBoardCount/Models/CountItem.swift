import Foundation

struct CountItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var emoji: String
    var sortOrder: Int

    init(id: UUID = UUID(), title: String, emoji: String, sortOrder: Int) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.sortOrder = sortOrder
    }
}
