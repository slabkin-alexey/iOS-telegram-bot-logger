// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TelegramReporter",
    platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v12)],
    products: [.library(name: "TelegramReporter", targets: ["TelegramReporter"])],
    targets: [
        .target(name: "TelegramReporter", path: "Sources"),
        .testTarget(name: "TelegramReporterTests", dependencies: ["TelegramReporter"], path: "Tests/TelegramReporterTests")
    ],
    swiftLanguageModes: [.v6]
)
