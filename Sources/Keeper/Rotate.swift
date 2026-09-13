import Foundation
import ImageIO

struct RotateError: LocalizedError {
    let fileName: String
    var errorDescription: String? { "COULD NOT ROTATE \(fileName)" }
}

// EXIF orientations: 1, 6, 3, 8 are 0°, 90°, 180°, 270° clockwise; 2, 7, 4, 5 are the mirrored equivalents.
private let clockwiseOrientation = [1: 6, 6: 3, 3: 8, 8: 1, 2: 7, 7: 4, 4: 5, 5: 2]

func rotatedOrientation(_ orientation: Int, clockwise: Bool) -> Int {
    if clockwise {
        return clockwiseOrientation[orientation] ?? 6
    }
    return clockwiseOrientation.first { $0.value == orientation }?.key ?? 8
}

// Rewrites only the orientation flag: the compressed image data is copied untouched, then swapped in atomically.
func rotateJPG(_ url: URL, clockwise: Bool) throws {
    let failure = RotateError(fileName: url.lastPathComponent)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let type = CGImageSourceGetType(source) else {
        throw failure
    }
    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    let orientation = properties?[kCGImagePropertyOrientation] as? Int ?? 1

    let temporary = url.deletingLastPathComponent().appendingPathComponent(".keeper-\(UUID().uuidString)")
    guard let destination = CGImageDestinationCreateWithURL(temporary as CFURL, type, 1, nil) else { throw failure }
    let options = [kCGImageDestinationOrientation: rotatedOrientation(orientation, clockwise: clockwise)] as CFDictionary
    do {
        guard CGImageDestinationCopyImageSource(destination, source, options, nil) else { throw failure }
        _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
    } catch {
        try? FileManager.default.removeItem(at: temporary)
        throw error
    }
}
