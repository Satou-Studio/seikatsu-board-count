import SwiftUI

struct CountItemEditorView: View {
    enum Mode {
        case add
        case edit(CountItem)
    }

    @EnvironmentObject private var store: CountStore
    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    @State private var emoji: String
    @State private var title: String

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            _emoji = State(initialValue: "")
            _title = State(initialValue: "")
        case .edit(let item):
            _emoji = State(initialValue: item.emoji)
            _title = State(initialValue: item.title)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 18) {
                    Card {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("なまえ")
                                .font(.headline)
                            TextField("はみがき", text: $title)
                                .font(.title2.weight(.semibold))
                                .textFieldStyle(.roundedBorder)

                            Text("マーク")
                                .font(.headline)
                            TextField("🪥", text: $emoji)
                                .font(.system(size: 42))
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Text("ほぞん")
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appOrange)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .add:
            return "ふやす"
        case .edit:
            return "なおす"
        }
    }

    private func save() {
        switch mode {
        case .add:
            let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
            store.addItem(title: title, emoji: trimmedEmoji.isEmpty ? "⭐️" : trimmedEmoji)
        case .edit(let item):
            let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
            store.updateItem(item, title: title, emoji: trimmedEmoji.isEmpty ? "⭐️" : trimmedEmoji)
        }
        dismiss()
    }
}
