import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayCountView()
                .tabItem {
                    Label("きょう", systemImage: "hand.thumbsup.fill")
                }

            HistoryView()
                .tabItem {
                    Label("きろく", systemImage: "calendar")
                }

            ParentSettingsGateView {
                SettingsView()
            }
            .tabItem {
                Label("せってい", systemImage: "gearshape.fill")
            }
        }
        .tint(.appOrange)
    }
}
