import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CountStore
    @State private var showingAddItem = false
    @State private var editingItem: CountItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
                    Section {
                        ForEach(store.sortedItems) { item in
                            Button {
                                editingItem = item
                            } label: {
                                HStack(spacing: 14) {
                                    Text(item.emoji)
                                        .font(.largeTitle)
                                        .frame(width: 48, height: 48)
                                    Text(item.title)
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.appText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .onDelete(perform: store.deleteItems)
                        .onMove(perform: store.moveItems)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("せってい")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("こうもくをふやす")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                CountItemEditorView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                CountItemEditorView(mode: .edit(item))
            }
        }
    }
}
