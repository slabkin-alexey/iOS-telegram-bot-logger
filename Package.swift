// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TelegramReporter",
    platforms: [.iOS(.v16), .tvOS(.v16)],
    products: [.library(name: "TelegramReporter", targets: ["TelegramReporter"])],
    targets: [.target(name: "TelegramReporter", path: "Sources")],
    swiftLanguageVersions: [.v5]
)
