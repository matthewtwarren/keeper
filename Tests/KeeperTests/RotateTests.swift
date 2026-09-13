import ImageIO
import UniformTypeIdentifiers
import XCTest

@testable import Keeper

final class RotateTests: XCTestCase {
    private var url: URL!

    // A noisy image, so any lossy re-encode would change the decoded pixels.
    override func setUpWithError() throws {
        url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).JPG")
        let context = CGContext(
            data: nil, width: 64, height: 32, bitsPerComponent: 8, bytesPerRow: 64 * 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )!
        let bytes = context.data!.assumingMemoryBound(to: UInt8.self)
        var seed: UInt32 = 42
        for offset in 0..<(64 * 32 * 4) {
            seed = seed &* 1_664_525 &+ 1_013_904_223
            bytes[offset] = UInt8(seed >> 24)
        }
        let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, context.makeImage()!, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: url)
    }

    private func orientation() -> Int {
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as! [CFString: Any]
        return properties[kCGImagePropertyOrientation] as? Int ?? 1
    }

    private func pixels() -> Data {
        let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary)!
        return CGImageSourceCreateImageAtIndex(source, 0, nil)!.dataProvider!.data! as Data
    }

    func testOrientationCycles() {
        var orientation = 1
        for expected in [6, 3, 8, 1] {
            orientation = rotatedOrientation(orientation, clockwise: true)
            XCTAssertEqual(orientation, expected)
        }
        XCTAssertEqual(rotatedOrientation(1, clockwise: false), 8)
        XCTAssertEqual(rotatedOrientation(6, clockwise: false), 1)
    }

    func testRotateIsLossless() throws {
        let original = pixels()
        try rotateJPG(url, clockwise: true)
        XCTAssertEqual(orientation(), 6)
        try rotateJPG(url, clockwise: false)
        try rotateJPG(url, clockwise: false)
        XCTAssertEqual(orientation(), 8)
        XCTAssertEqual(pixels(), original)
    }

    func testRotateKeepsFinderTagsAndLeavesNoTempFiles() throws {
        try writeColour(.green, to: url)
        try rotateJPG(url, clockwise: true)
        XCTAssertEqual(readColour(URL(fileURLWithPath: url.path)), .green)
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
            .filter { $0.hasPrefix(".keeper-") }
        XCTAssertEqual(leftovers, [])
    }
}
