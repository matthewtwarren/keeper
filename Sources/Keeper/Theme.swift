import SwiftUI

enum Theme {
    static let background = Color(hex: 0x101015)
    static let surface = Color(hex: 0x18181F)
    static let border = Color(hex: 0x2A2A35)
    static let accent = Color(hex: 0x506385)
    static let text = Color(hex: 0xF1F0E1)
    static let muted = Color(hex: 0x6B6B80)

    static func mono(_ size: CGFloat, bold: Bool = false) -> Font {
        .custom(bold ? "SpaceMono-Bold" : "SpaceMono-Regular", size: size)
    }
}

extension TagColour {
    var swatch: Color {
        switch self {
        case .red: Color(hex: 0xF25A55)
        case .yellow: Color(hex: 0xF5C33B)
        case .green: Color(hex: 0x5BC236)
        case .blue: Color(hex: 0x3D8BF7)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

struct Chip: View {
    let label: String
    var key: String?
    var swatch: Color?
    var selected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let key {
                    Text(key).foregroundStyle(Theme.muted)
                }
                if let swatch {
                    Circle().fill(swatch).frame(width: 8, height: 8)
                }
                Text(label)
            }
            .font(Theme.mono(11))
            .foregroundStyle(selected ? Theme.text : Color(hex: 0x8AA0BE))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(selected ? Theme.accent.opacity(0.35) : .clear)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(selected ? Theme.accent : Theme.border))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
