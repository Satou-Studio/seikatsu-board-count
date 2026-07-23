import SwiftUI

struct ParentSettingsGateView<Content: View>: View {
    @State private var isUnlocked = false
    @State private var tapCount = 0
    @ViewBuilder let content: Content

    var body: some View {
        if isUnlocked {
            content
        } else {
            NavigationStack {
                ZStack {
                    Color.appBackground.ignoresSafeArea()

                    VStack(spacing: 22) {
                        EmojiCircle(emoji: "🔒", size: 82)

                        Text("おうちのひと")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.appText)

                        Text("みどりのボタンを3かいおしてね")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Button {
                            tapCount += 1
                            if tapCount >= 3 {
                                isUnlocked = true
                            }
                        } label: {
                            Text(tapCount >= 2 ? "ひらく" : "おす")
                                .font(.title.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appGreen)
                        .padding(.horizontal, 28)
                    }
                    .padding(20)
                }
                .navigationTitle("せってい")
            }
        }
    }
}
