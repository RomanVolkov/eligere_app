// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EligereTests",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/LebJe/TOMLKit", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "Eligere",
            dependencies: [
                .product(name: "TOMLKit", package: "TOMLKit"),
            ]
        ),
        .testTarget(
            name: "EligereTests",
            dependencies: ["Eligere"],
            path: "Tests/EligereTests"
        ),
    ]
)
