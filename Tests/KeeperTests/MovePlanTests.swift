import XCTest

@testable import Keeper

final class MovePlanTests: XCTestCase {
    private var folder: URL!

    override func setUpWithError() throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: folder)
    }

    private func touch(_ names: String...) {
        for name in names {
            FileManager.default.createFile(atPath: folder.appendingPathComponent(name).path, contents: Data())
        }
    }

    private func photo(_ name: String, jpg: Bool = true, raf: Bool = true, mark: Mark = .none) -> Photo {
        Photo(
            baseName: name,
            jpg: jpg ? folder.appendingPathComponent("\(name).JPG") : nil,
            raf: raf ? folder.appendingPathComponent("\(name).RAF") : nil,
            mark: mark
        )
    }

    func testScanPairsJpgAndRafCaseInsensitivelyAndIgnoresOtherFiles() throws {
        touch("DSCF0001.JPG", "DSCF0001.RAF", "dscf0002.jpg", "DSCF0002.RAF", "DSCF0003.RAF", "clip.MOV", ".hidden.JPG")
        let photos = try scanFolder(folder)
        XCTAssertEqual(photos.map { $0.baseName.uppercased() }, ["DSCF0001", "DSCF0002", "DSCF0003"])
        XCTAssertEqual(photos.map { $0.files.count }, [2, 2, 1])
        XCTAssertNil(photos[2].jpg)
    }

    func testDeleteMovesBothFiles() {
        let plan = movePlan([photo("A", mark: .delete)], keepRawForUntagged: true)
        XCTAssertEqual(plan.map(\.lastPathComponent), ["A.JPG", "A.RAF"])
    }

    func testTaggedNeverMoves() {
        let plan = movePlan([photo("A", mark: .colour(.red))], keepRawForUntagged: false)
        XCTAssertEqual(plan, [])
    }

    func testUntaggedMovesRafByDefaultAndKeepsItWithToggle() {
        let photos = [photo("A"), photo("B", raf: false)]
        XCTAssertEqual(movePlan(photos, keepRawForUntagged: false).map(\.lastPathComponent), ["A.RAF"])
        XCTAssertEqual(movePlan(photos, keepRawForUntagged: true), [])
    }

    func testUntaggedRafWithoutJpgIsKept() {
        XCTAssertEqual(movePlan([photo("A", jpg: false)], keepRawForUntagged: false), [])
    }

    func testMovesNeverOverwrite() throws {
        touch("A.RAF")
        let destination = folder.appendingPathComponent("delete")
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: destination.appendingPathComponent("A.RAF").path, contents: Data())

        let result = performMoves([folder.appendingPathComponent("A.RAF")], into: destination)

        XCTAssertEqual(result.moved, 1)
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(atPath: destination.path).sorted(),
            ["A 2.RAF", "A.RAF"]
        )
    }

    func testColourTagRoundTripKeepsOtherTags() throws {
        touch("A.JPG")
        let url = folder.appendingPathComponent("A.JPG")
        try (url as NSURL).setResourceValue(["Work"], forKey: .tagNamesKey)

        try writeColour(.red, to: url)
        XCTAssertEqual(readColour(URL(fileURLWithPath: url.path)), .red)

        try writeColour(nil, to: url)
        let tags = try URL(fileURLWithPath: url.path).resourceValues(forKeys: [.tagNamesKey]).tagNames
        XCTAssertEqual(tags, ["Work"])
    }
}
