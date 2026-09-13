import Foundation

// Nothing is ever deleted: files are only moved into the delete folder.
func movePlan(_ photos: [Photo], keepRawForUntagged: Bool) -> [URL] {
    photos.flatMap { photo -> [URL] in
        switch photo.mark {
        case .delete:
            return photo.files
        case .colour:
            return []
        case .none:
            guard !keepRawForUntagged, photo.jpg != nil, let raf = photo.raf else { return [] }
            return [raf]
        }
    }
}

struct MoveResult {
    var moved = 0
    var errors: [String] = []
}

func performMoves(_ urls: [URL], into destination: URL) -> MoveResult {
    var result = MoveResult()
    do {
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
    } catch {
        result.errors.append("COULD NOT CREATE \(destination.lastPathComponent): \(error.localizedDescription)")
        return result
    }
    for url in urls {
        do {
            try FileManager.default.moveItem(at: url, to: availableURL(for: url.lastPathComponent, in: destination))
            result.moved += 1
        } catch {
            result.errors.append("\(url.lastPathComponent): \(error.localizedDescription)")
        }
    }
    return result
}

func availableURL(for fileName: String, in folder: URL) -> URL {
    let candidate = folder.appendingPathComponent(fileName)
    guard FileManager.default.fileExists(atPath: candidate.path) else { return candidate }
    let baseName = (fileName as NSString).deletingPathExtension
    let fileExtension = (fileName as NSString).pathExtension
    var number = 2
    while true {
        let numbered = folder.appendingPathComponent("\(baseName) \(number).\(fileExtension)")
        if !FileManager.default.fileExists(atPath: numbered.path) { return numbered }
        number += 1
    }
}
