import SwiftUI

struct HelpView: View {
    let close: () -> Void

    private var keys: [(String, String)] {
        let colours = TagColour.allCases.map { $0.rawValue.uppercased() }.joined(separator: " / ")
        return [
            ("← →", "PREVIOUS / NEXT"),
            ("1–\(TagColour.allCases.count)", "TAG \(colours) (TOGGLES)"),
            ("D", "FLAG FOR DELETE (TOGGLES)"),
            ("S / SPACE", "SKIP (CLEARS ANY MARK)"),
            ("R / ⇧R", "ROTATE THE JPG CLOCKWISE / ANTICLOCKWISE"),
            ("C", "COMPARE: PIN THIS PHOTO ON THE LEFT, BROWSE ON THE RIGHT"),
            ("X", "SWAP THE PINNED AND CURRENT PHOTOS"),
            ("⌘↩", "REVIEW AND MOVE"),
            ("⌘O", "OPEN FOLDER"),
            ("H", "HELP"),
        ]
    }

    private let rules = [
        ("TAGGED", "PHOTOS KEEP THE JPG AND THE RAF. THE FINDER TAG IS WRITTEN TO BOTH FILES STRAIGHT AWAY."),
        ("FLAGGED", "PHOTOS MOVE BOTH THE JPG AND THE RAF TO DELETE/."),
        ("ROTATE", "REWRITES ONLY THE JPG'S ORIENTATION FLAG. THE IMAGE DATA IS UNTOUCHED (LOSSLESS) AND THE RAF IS NEVER MODIFIED."),
        ("COMPARE", "TAG, DELETE, SKIP AND ROTATE APPLY TO THE PHOTO ON THE RIGHT."),
        ("UNTAGGED", "PHOTOS KEEP THE JPG. THE RAF MOVES TO DELETE/ UNLESS YOU PICK JPG + RAF ON THE SUMMARY SCREEN. A RAF WITH NO JPG IS ALWAYS KEPT."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("KEEPER · HELP").font(Theme.mono(15, bold: true))
            ScrollView {
                content.padding(.trailing, 12)
            }
            .frame(height: 420)

            HStack {
                Spacer()
                Chip(label: "CLOSE", key: "ESC", action: close)
                    .keyboardShortcut(.cancelAction)
                    .background {
                        Button("", action: close)
                            .keyboardShortcut("h", modifiers: [])
                            .opacity(0)
                    }
            }
        }
        .font(Theme.mono(11))
        .foregroundStyle(Theme.text)
        .padding(24)
        .frame(width: 540)
        .background(Theme.surface)
        .preferredColorScheme(.dark)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("A SMALL MACOS APP FOR PROCESSING SHOTS FROM MY FUJIFILM CAMERA.")
                Text(
                    "OPEN A FOLDER, SCROLL THROUGH EACH PHOTO WITH A QUICKLOOK PREVIEW; TAG FAVOURITE PHOTOS WITH A "
                        + "COLOUR THAT APPEARS IN FINDER; AND FLAG PHOTOS FOR DELETION. PHOTOS CAN ALSO BE ROTATED AND "
                        + "COMPARED SIDE-BY-SIDE."
                )
                Text("EACH JPEG (JPG) AND RAW (RAF) WITH THE SAME NAME ARE TREATED AS ONE PHOTO.")
                Text("KEEPER NEVER DELETES ANYTHING. \"DELETED\" FILES ARE SIMPLY MOVED TO <FOLDER>/DELETE/ AFTER YOU REVIEW.")
                    .foregroundStyle(Theme.text)
            }
            .foregroundStyle(Theme.muted)
            .fixedSize(horizontal: false, vertical: true)

            Rectangle().fill(Theme.border).frame(height: 1)
            section("KEYS", keys, labelWidth: 90)
            Rectangle().fill(Theme.border).frame(height: 1)
            section("RULES", rules, labelWidth: 90)
        }
    }

    private func section(_ title: String, _ lines: [(String, String)], labelWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(Theme.mono(12, bold: true))
            ForEach(lines, id: \.0) { label, description in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(label).frame(width: labelWidth, alignment: .leading)
                    Text(description)
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
