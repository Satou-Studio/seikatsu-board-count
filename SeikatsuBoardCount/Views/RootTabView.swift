import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var store: CountStore

    var body: some View {
        if store.needsRecovery {
            CountRecoveryView()
        } else {
            normalTabs
        }
    }

    private var normalTabs: some View {
        TabView {
            TodayCountView()
                .tabItem {
                    Label("きょう", systemImage: "hand.thumbsup.fill")
                }

            HistoryView()
                .tabItem {
                    Label("きろく", systemImage: "calendar")
                }
        }
        .tint(.appOrange)
    }
}

private struct CountRecoveryView: View {
    @EnvironmentObject private var store: CountStore
    @State private var confirmingStartOver = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "exclamationmark.shield")
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                Text("recovery.title")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Text("recovery.explanation")
                Text("recovery.options")
                if store.recoveryBackupFailed {
                    Text("recovery.backupFailed")
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("recovery.backupFailed")
                }
                Button(action: store.retryLoading) {
                    Text("recovery.retry")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(8)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("recovery.retry")
                Button {
                    confirmingStartOver = true
                } label: {
                    Text("recovery.startOver")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(8)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("recovery.startOver")
            }
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.primary)
        .tint(.primary)
        .background(Color(uiColor: .systemBackground))
        .alert("recovery.confirmTitle", isPresented: $confirmingStartOver) {
            Button("recovery.cancel", role: .cancel) {}
            Button("recovery.confirm", role: .destructive) {
                store.startOverPreservingOriginal()
            }
        } message: {
            Text("recovery.confirmMessage")
        }
    }
}
