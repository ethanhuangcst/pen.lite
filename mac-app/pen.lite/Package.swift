// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Pen",
    platforms: [
       .macOS(.v13)
    ],
    products: [
        .executable(name: "Pen", targets: ["Pen"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Pen",
            dependencies: [],
            path: "Sources",
            sources: ["App", "Extensions", "Models", "Services", "Views"],
            resources: [
                .process("../Resources/Assets"),
                .copy("../Resources/config"),
                .copy("../Resources/prompts"),
                .process("../Resources/en.lproj"),
                .process("../Resources/zh-Hans.lproj")
            ]
        ),
        .testTarget(
            name: "PenTests",
            dependencies: ["Pen"],
            path: "Tests"
        )
    ]
)
