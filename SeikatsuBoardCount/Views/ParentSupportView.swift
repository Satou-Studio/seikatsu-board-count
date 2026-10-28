import SwiftUI

// Deliberately independent of CountStore: external links never read records.
enum ParentSupportContent {
    static let supportURL = URL(string: "https://satou-studio.github.io/seikatsu-board-site/count-support.html")!
    static let reviewURL = URL(string: "https://apps.apple.com/app/id6794626819?action=write-review")!
}

struct ParentSupportEntry: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("support.title", systemImage: "info.circle")
                .font(.subheadline)
                .frame(minHeight: 44)
                .padding(.horizontal, 12)
        }
        .accessibilityLabel(Text("support.title"))
        .accessibilityIdentifier("support.entry")
        .sheet(isPresented: $isPresented) { ParentSupportView() }
    }
}

struct ParentSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showingLinkFailure = false

    var body: some View {
        NavigationStack {
            ScrollView {
              VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("support.introduction")
                    action("support.review", detail: "support.reviewDetail", icon: "square.and.pencil", id: "support.review") {
                        open(ParentSupportContent.reviewURL)
                    }
                    action("support.help", detail: "support.webDetail", icon: "questionmark.circle", id: "support.help") {
                        open(ParentSupportContent.supportURL)
                    }
                }
              }
              .font(.body)
              .fixedSize(horizontal: false, vertical: true)
              .padding(20)
            }
            .safeAreaInset(edge: .top) {
                supportHeader(title: "support.title", closeID: "support.close") { dismiss() }
            }
            .alert("support.linkFailed", isPresented: $showingLinkFailure) {
                Button("support.close", role: .cancel) {}
            } message: {
                Text("support.linkFailedDetail")
            }
        }
        .tint(.primary)
    }

    // Navigation-bar text caps its scaling on small screens. Keep the close
    // action outside that bar so it follows the full accessibility size range.
    private func supportHeader(title: LocalizedStringKey, closeID: String, close: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            Button(action: close) {
                Text("support.close")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityIdentifier(closeID)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }

    private func action(_ title: LocalizedStringKey, detail: LocalizedStringKey, icon: String, id: String, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon).accessibilityHidden(true)
                    Text(title).fixedSize(horizontal: false, vertical: true)
                }
                .font(.body.weight(.semibold))
                Text(detail).font(.subheadline).foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }

    private func open(_ url: URL) {
        openURL(url) { accepted in
            if !accepted { showingLinkFailure = true }
        }
    }
}
