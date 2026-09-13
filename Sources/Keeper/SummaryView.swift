import SwiftUI

struct SummaryView: View {
    let session: Session

    var body: some View {
        let moves = session.plannedMoves
        VStack(alignment: .leading, spacing: 16) {
            Text("SUMMARY").font(Theme.mono(15, bold: true))

            VStack(alignment: .leading, spacing: 6) {
                line("TAGGED · KEEP JPG + RAF", session.count { $0.colour != nil })
                line("FLAGGED · MOVE JPG + RAF", session.count { $0 == .delete })
                line("UNTAGGED", session.count { $0 == .none })
            }

            HStack(spacing: 8) {
                Text("UNTAGGED:").foregroundStyle(Theme.muted)
                Chip(label: "JPG ONLY", selected: !session.keepRawForUntagged) { session.keepRawForUntagged = false }
                Chip(label: "JPG + RAF", selected: session.keepRawForUntagged) { session.keepRawForUntagged = true }
            }

            Rectangle().fill(Theme.border).frame(height: 1)

            Text("\(moves.count) FILES TO MOVE").font(Theme.mono(12, bold: true))
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(moves, id: \.self) { url in
                        Text(url.lastPathComponent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 180)
            .foregroundStyle(Theme.muted)

            Text("NOTHING IS DELETED. FILES ARE MOVED TO \(session.folder?.lastPathComponent.uppercased() ?? "")/DELETE.")
                .foregroundStyle(Theme.muted)

            HStack(spacing: 8) {
                Spacer()
                Chip(label: "CANCEL", key: "ESC") { session.showingSummary = false }
                    .keyboardShortcut(.cancelAction)
                Chip(label: "MOVE \(moves.count) FILES", key: "↩", selected: true) { session.commitMoves() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(moves.isEmpty)
            }
        }
        .font(Theme.mono(11))
        .foregroundStyle(Theme.text)
        .padding(24)
        .frame(width: 480)
        .background(Theme.surface)
        .preferredColorScheme(.dark)
    }

    private func line(_ label: String, _ count: Int) -> some View {
        HStack {
            Text(label).foregroundStyle(Theme.muted)
            Spacer()
            Text("\(count)")
        }
    }
}
