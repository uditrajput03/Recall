// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "Recall",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Recall",
            targets: ["RecallApp"]
        ),
        .library(
            name: "RecallCore",
            targets: ["RecallCore"]
        )
    ],
    targets: [
        .target(
            name: "RecallCore",
            dependencies: [],
            path: "Sources/RecallCore"
        ),
        .executableTarget(
            name: "RecallApp",
            dependencies: ["RecallCore"],
            path: "Sources/RecallApp"
        ),
        .testTarget(
            name: "RecallTests",
            dependencies: ["RecallCore"],
            path: "Tests/RecallTests"
        )
    ]
)
