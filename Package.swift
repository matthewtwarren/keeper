// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Keeper",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Keeper", path: "Sources/Keeper"),
        .testTarget(name: "KeeperTests", dependencies: ["Keeper"], path: "Tests/KeeperTests"),
    ]
)
