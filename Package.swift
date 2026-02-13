// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TelegramReporter",
    platforms: [.iOS(.v18), .tvOS(.v18), .macOS(.v15)],
    products: [.library(name: "TelegramReporter", targets: ["TelegramReporter"])],
    targets: [
        .target(name: "TelegramReporter", path: "Sources"),
        .testTarget(name: "TelegramReporterTests", dependencies: ["TelegramReporter"], path: "Tests/TelegramReporterTests")
    ],
    swiftLanguageModes: [.v6]
)
