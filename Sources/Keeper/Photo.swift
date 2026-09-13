import Foundation

enum TagColour: String, CaseIterable {
    case red = "Red"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
}

enum Mark: Equatable {
    case none
    case colour(TagColour)
    case delete

    var colour: TagColour? {
        if case .colour(let colour) = self { return colour }
        return nil
    }
}

struct Photo: Identifiable, Equatable {
    let baseName: String
    var jpg: URL?
    var raf: URL?
    var mark: Mark = .none

    var id: String { baseName }
    var previewURL: URL? { jpg ?? raf }
    var files: [URL] { [jpg, raf].compactMap { $0 } }
}

func scanFolder(_ folder: URL) throws -> [Photo] {
    let urls = try FileManager.default.contentsOfDirectory(
        at: folder,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    )
    var photosByKey: [String: Photo] = [:]
    for url in urls {
        let fileExtension = url.pathExtension.lowercased()
        guard ["jpg", "jpeg", "raf"].contains(fileExtension) else { continue }
        guard (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }
        let baseName = url.deletingPathExtension().lastPathComponent
        let key = baseName.lowercased()
        var photo = photosByKey[key] ?? Photo(baseName: baseName)
        if fileExtension == "raf" {
            photo.raf = url
        } else {
            photo.jpg = url
        }
        photosByKey[key] = photo
    }
    return photosByKey.values
        .map { photo in
            var photo = photo
            if let colour = photo.files.lazy.compactMap(readColour).first {
                photo.mark = .colour(colour)
            }
            return photo
        }
        .sorted { $0.baseName.localizedStandardCompare($1.baseName) == .orderedAscending }
}

func readColour(_ url: URL) -> TagColour? {
    let tags = (try? url.resourceValues(forKeys: [.tagNamesKey]).tagNames) ?? []
    return TagColour.allCases.first { tags.contains($0.rawValue) }
}

// Replaces only KEEPER's colour tags, leaving any other Finder tags in place.
func writeColour(_ colour: TagColour?, to url: URL) throws {
    let colourNames = Set(TagColour.allCases.map(\.rawValue))
    let existing = (try URL(fileURLWithPath: url.path).resourceValues(forKeys: [.tagNamesKey]).tagNames) ?? []
    var tags = existing.filter { !colourNames.contains($0) }
    if let colour {
        tags.append(colour.rawValue)
    }
    try (url as NSURL).setResourceValue(tags, forKey: .tagNamesKey)
}
