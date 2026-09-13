import Foundation
import Observation

@Observable
final class Session {
    var folder: URL?
    var photos: [Photo] = []
    var index = 0
    var keepRawForUntagged = false
    var showingSummary = false
    var message: String?
    var pinnedID: String?
    var previewRevision = 0

    var current: Photo? { photos.indices.contains(index) ? photos[index] : nil }
    var pinned: Photo? { photos.first { $0.id == pinnedID } }
    var deleteFolder: URL? { folder?.appendingPathComponent("delete") }
    var plannedMoves: [URL] { movePlan(photos, keepRawForUntagged: keepRawForUntagged) }

    func count(_ matches: (Mark) -> Bool) -> Int {
        photos.filter { matches($0.mark) }.count
    }

    func open(_ url: URL) {
        folder = url
        index = 0
        message = nil
        pinnedID = nil
        reload()
    }

    func reload() {
        guard let folder else { return }
        do {
            photos = try scanFolder(folder)
        } catch {
            photos = []
            message = error.localizedDescription
        }
        index = min(index, max(photos.count - 1, 0))
        if pinned == nil { pinnedID = nil }
    }

    func next() {
        if index < photos.count - 1 { index += 1 }
    }

    func previous() {
        if index > 0 { index -= 1 }
    }

    func toggle(_ mark: Mark) {
        guard let photo = current else { return }
        setMark(photo.mark == mark ? .none : mark)
        next()
    }

    func skip() {
        setMark(.none)
        next()
    }

    func rotate(clockwise: Bool) {
        guard let photo = current else { return }
        guard let jpg = photo.jpg else {
            message = "\(photo.baseName) HAS NO JPG TO ROTATE"
            return
        }
        do {
            try rotateJPG(jpg, clockwise: clockwise)
            previewRevision += 1
        } catch {
            message = error.localizedDescription
        }
    }

    func toggleCompare() {
        if pinnedID != nil {
            pinnedID = nil
            return
        }
        guard let photo = current else { return }
        pinnedID = photo.id
        next()
    }

    func swapCompare() {
        guard let photo = current, let pinnedIndex = photos.firstIndex(where: { $0.id == pinnedID }) else { return }
        pinnedID = photo.id
        index = pinnedIndex
    }

    func commitMoves() {
        guard let deleteFolder else { return }
        let result = performMoves(plannedMoves, into: deleteFolder)
        showingSummary = false
        index = 0
        reload()
        message = (["MOVED \(result.moved) FILES TO DELETE/"] + result.errors).joined(separator: "\n")
    }

    private func setMark(_ mark: Mark) {
        guard let photo = current else { return }
        if photo.mark.colour != mark.colour {
            do {
                for url in photo.files {
                    try writeColour(mark.colour, to: url)
                }
            } catch {
                message = "COULD NOT TAG \(photo.baseName): \(error.localizedDescription)"
                return
            }
        }
        photos[index].mark = mark
    }
}
