import SwiftUI

@main
struct SeikatsuBoardCountApp: App {
    @StateObject private var store = CountStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
