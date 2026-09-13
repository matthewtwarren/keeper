import SwiftUI

struct ContentView: View {
    @State private var session = Session()
    @State private var choosingFolder = false
    @State private var showingHelp = false

    var body: some View {
        HStack(spacing: 0) {
            Sidebar(session: session, openFolder: { choosingFolder = true }, openHelp: { showingHelp = true })
            Rectangle().fill(Theme.border).frame(width: 1)
            main
        }
        .background(Theme.background)
        .foregroundStyle(Theme.text)
        .font(Theme.mono(12))
        .fileImporter(isPresented: $choosingFolder, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                session.open(url)
            }
        }
        .sheet(isPresented: $session.showingSummary) {
            SummaryView(session: session)
        }
        .sheet(isPresented: $showingHelp) {
            HelpView { showingHelp = false }
        }
    }

    @ViewBuilder
    private var main: some View {
        if let photo = session.current {
            VStack(spacing: 0) {
                header(photo)
                Rectangle().fill(Theme.border).frame(height: 1)
                if let pinned = session.pinned {
                    HStack(spacing: 0) {
                        pane(pinned, caption: "PINNED")
                        Rectangle().fill(Theme.border).frame(width: 1)
                        pane(photo, caption: "CURRENT")
                    }
                } else {
                    QuickLookView(url: photo.previewURL, revision: session.previewRevision)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Rectangle().fill(Theme.border).frame(height: 1)
                actions(photo)
            }
        } else {
            VStack(spacing: 16) {
                Text(session.folder == nil ? "NO FOLDER OPEN" : "NO PHOTOS IN THIS FOLDER")
                    .foregroundStyle(Theme.muted)
                Chip(label: "OPEN FOLDER", key: "⌘O") { choosingFolder = true }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func header(_ photo: Photo) -> some View {
        HStack(spacing: 12) {
            Text(photo.baseName.uppercased()).font(Theme.mono(15, bold: true))
            Text("\(session.index + 1) / \(session.photos.count)").foregroundStyle(Theme.muted)
            Spacer()
            Text(fileLabel(photo)).foregroundStyle(Theme.muted)
            Chip(label: "↺", key: "⇧R") { session.rotate(clockwise: false) }
                .keyboardShortcut("r", modifiers: .shift)
            Chip(label: "↻", key: "R") { session.rotate(clockwise: true) }
                .keyboardShortcut("r", modifiers: [])
            Chip(label: "COMPARE", key: "C", selected: session.pinned != nil, action: session.toggleCompare)
                .keyboardShortcut("c", modifiers: [])
            if session.pinned != nil {
                Chip(label: "SWAP", key: "X", action: session.swapCompare)
                    .keyboardShortcut("x", modifiers: [])
            }
            Chip(label: "‹", action: session.previous)
                .keyboardShortcut(.leftArrow, modifiers: [])
            Chip(label: "›", action: session.next)
                .keyboardShortcut(.rightArrow, modifiers: [])
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func pane(_ photo: Photo, caption: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(caption).foregroundStyle(Theme.muted)
                MarkBadge(mark: photo.mark)
                Text(photo.baseName.uppercased())
                Spacer()
            }
            .font(Theme.mono(10))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            QuickLookView(url: photo.previewURL, revision: session.previewRevision)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func actions(_ photo: Photo) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(TagColour.allCases.enumerated()), id: \.element) { position, colour in
                Chip(
                    label: colour.rawValue.uppercased(),
                    key: "\(position + 1)",
                    swatch: colour.swatch,
                    selected: photo.mark == .colour(colour)
                ) { session.toggle(.colour(colour)) }
                    .keyboardShortcut(KeyEquivalent(Character("\(position + 1)")), modifiers: [])
            }
            Chip(label: "DELETE", key: "D", selected: photo.mark == .delete) { session.toggle(.delete) }
                .keyboardShortcut("d", modifiers: [])
            Chip(label: "SKIP", key: "S") { session.skip() }
                .keyboardShortcut("s", modifiers: [])
            Button("", action: session.skip)
                .keyboardShortcut(.space, modifiers: [])
                .opacity(0)
                .frame(width: 0, height: 0)
            Spacer()
            Chip(label: "REVIEW", key: "⌘↩", selected: true) { session.showingSummary = true }
                .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Theme.surface)
    }

    private func fileLabel(_ photo: Photo) -> String {
        switch (photo.jpg, photo.raf) {
        case (.some, .some): "JPG + RAF"
        case (.some, .none): "JPG ONLY"
        default: "RAF ONLY"
        }
    }
}

private struct MarkBadge: View {
    let mark: Mark

    var body: some View {
        Group {
            switch mark {
            case .colour(let colour): Circle().fill(colour.swatch).frame(width: 8, height: 8)
            case .delete: Text("×").foregroundStyle(Theme.text)
            case .none: Color.clear
            }
        }
        .frame(width: 10, height: 10)
    }
}

private struct Sidebar: View {
    let session: Session
    let openFolder: () -> Void
    let openHelp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("KEEPER")
                .font(Theme.mono(18, bold: true))
                .tracking(3)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            Rectangle().fill(Theme.border).frame(height: 1)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(session.photos.indices, id: \.self) { position in
                            row(
                                session.photos[position],
                                isCurrent: position == session.index,
                                isPinned: session.photos[position].id == session.pinnedID
                            )
                                .id(position)
                                .onTapGesture { session.index = position }
                        }
                    }
                    .padding(8)
                }
                .onChange(of: session.index) { _, position in
                    proxy.scrollTo(position, anchor: .center)
                }
            }
            Rectangle().fill(Theme.border).frame(height: 1)
            footer
        }
        .frame(width: 220)
    }

    private func row(_ photo: Photo, isCurrent: Bool, isPinned: Bool) -> some View {
        HStack(spacing: 8) {
            MarkBadge(mark: photo.mark)
            Text(photo.baseName.uppercased())
                .strikethrough(photo.mark == .delete)
                .lineLimit(1)
            Spacer()
            if isPinned {
                Text("PIN").font(Theme.mono(9)).foregroundStyle(Theme.accent)
            }
            if photo.raf != nil {
                Text("RAF").font(Theme.mono(9)).foregroundStyle(Theme.muted)
            }
        }
        .font(Theme.mono(11))
        .foregroundStyle(isCurrent ? Theme.text : Theme.muted)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isCurrent ? Theme.surface : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .contentShape(Rectangle())
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let folder = session.folder {
                Text(folder.lastPathComponent.uppercased()).lineLimit(1)
                Text(
                    "\(session.photos.count) PHOTOS\n"
                        + "\(session.count { $0.colour != nil }) TAGGED · \(session.count { $0 == .delete }) DELETE"
                )
                .foregroundStyle(Theme.muted)
            }
            if let message = session.message {
                Text(message).foregroundStyle(Theme.accent)
            }
            HStack(spacing: 8) {
                Chip(label: "OPEN FOLDER", key: "⌘O", action: openFolder)
                    .keyboardShortcut("o", modifiers: .command)
                Chip(label: "HELP", key: "H", action: openHelp)
                    .keyboardShortcut("h", modifiers: [])
            }
        }
        .font(Theme.mono(10))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}
