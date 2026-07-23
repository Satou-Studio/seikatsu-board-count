import SwiftUI

extension Color {
    static let appBackground = Color(red: 1.0, green: 0.96, blue: 0.86)
    static let appOrange = Color(red: 0.96, green: 0.56, blue: 0.23)
    static let appGreen = Color(red: 0.36, green: 0.68, blue: 0.36)
    static let appBlue = Color(red: 0.28, green: 0.55, blue: 0.86)
    static let appText = Color(red: 0.22, green: 0.18, blue: 0.14)
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct EmojiCircle: View {
    let emoji: String
    var size: CGFloat = 58

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.48))
            .frame(width: size, height: size)
            .background(Color.appBackground)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

struct PrimaryCountButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("できた！")
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.appOrange)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
