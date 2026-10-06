import AppKit

// Deterministic layout only. Screenshots are scaled as a whole, without retouching UI.
let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let cream = color(0xFFF6E8), ink = color(0x49382D), orange = color(0xB44B23)
func rectangle(_ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat, canvasHeight: CGFloat = 2868) -> CGRect {
    CGRect(x: x, y: canvasHeight - top - h, width: w, height: h)
}
func label(_ string: String, top: CGFloat, size: CGFloat, height: CGFloat, weight: NSFont.Weight = .bold, tint: NSColor = ink) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = 8
    let font = NSFont(name: weight == .bold ? "HiraginoSans-W6" : "HiraginoSans-W3", size: size) ?? .systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: tint, .paragraphStyle: paragraph]
    let text = NSAttributedString(string: string, attributes: attrs)
    let needed = text.boundingRect(with: CGSize(width: 1192, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading])
    precondition(needed.height <= height, "Text clipped: \(string), height \(needed.height)")
    text.draw(in: rectangle(64, top, 1192, height))
}
func canvas(width: Int, height: Int, draw: () throws -> Void, output: URL) throws {
    let bitmap = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                           bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                           bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    let context = NSGraphicsContext(cgContext: bitmap, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    cream.setFill()
    CGRect(x: 0, y: 0, width: width, height: height).fill()
    try draw()
    NSGraphicsContext.restoreGraphicsState()
    let rep = NSBitmapImageRep(cgImage: bitmap.makeImage()!)
    try rep.representation(using: .png, properties: [:])!.write(to: output)
}
let pages = [
    ("01-today", "できたら、ひと押し", "まちがえても「もどす」で取り消せます"),
    ("02-history", "7日間を\n親子で振り返る", "昨日も、その前の日も、いっしょに。"),
    ("03-add-item", "家族の「できた」を\n追加", "なまえとマークを決めて「ほぞん」")
]
for (name, title, subtitle) in pages {
    let source = root.appendingPathComponent("raw/\(name).png")
    let image = NSImage(contentsOf: source)!
    let rep = NSBitmapImageRep(data: try Data(contentsOf: source))!
    precondition(rep.pixelsWide == 1320 && rep.pixelsHigh == 2868)
    try canvas(width: 1320, height: 2868, draw: {
        label("生活ボードカウント", top: 65, size: 48, height: 75, weight: .regular, tint: orange)
        label(title, top: title.contains("\n") ? 144 : 208, size: title.contains("\n") ? 80 : 92, height: 260)
        label(subtitle, top: 409, size: 41, height: 70, weight: .regular)
        let screen = rectangle(120, 492, 1080, 1080 * 2868 / 1320)
        color(0xE6D5BD).setFill()
        NSBezierPath(roundedRect: screen.insetBy(dx: -5, dy: -5), xRadius: 7, yRadius: 7).fill()
        image.draw(in: screen, from: .zero, operation: .sourceOver, fraction: 1)
    }, output: root.appendingPathComponent("images/\(name).png"))
}
try canvas(width: 1380, height: 980, draw: {
    for (index, page) in pages.enumerated() {
        let image = NSImage(contentsOf: root.appendingPathComponent("images/\(page.0).png"))!
        image.draw(in: CGRect(x: 30 + index * 450, y: 34, width: 420, height: 420 * 2868 / 1320), from: .zero, operation: .sourceOver, fraction: 1)
    }
}, output: root.appendingPathComponent("preview.png"))
for file in ["subtitle.txt", "promotional-text.txt", "description.txt", "keywords.txt"] {
    let value = try String(contentsOf: root.appendingPathComponent(file), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    print("\(file): \(value.count) characters; \(value.utf8.count) UTF-8 bytes")
    let limit = ["subtitle.txt": 30, "promotional-text.txt": 170, "description.txt": 4000, "keywords.txt": 100][file]!
    precondition(value.count <= limit)
    if file == "keywords.txt" { precondition(value.utf8.count <= 100) }
}
