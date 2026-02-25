import XCTest
@testable import TelegramReporter

final class MessageBuilderTests: XCTestCase {
    func testFirstLaunchIncludesHeaderAndHashtag() {
        let message = MessageBuilder.build(.firstLaunch, additional: "QA")

        XCTAssertTrue(message.contains("✅ First Launch"))
        XCTAssertTrue(message.contains("📱 App:"))
        XCTAssertTrue(message.contains(" • QA"))
        XCTAssertTrue(message.contains("\n\n#"))
    }

    func testCustomEventSortsAndNormalizesDetails() {
        let event = TelegramReporterEvent.custom(
            title: "Sync Failed",
            details: [
                "zeta": "line1\nline2",
                "alpha": " ok "
            ]
        )

        let message = MessageBuilder.build(event, additional: "")

        XCTAssertTrue(message.contains("🧩 Sync Failed"))
        XCTAssertTrue(message.contains("📋 Details:"))
        XCTAssertTrue(message.contains("• alpha: ok"))
        XCTAssertTrue(message.contains("• zeta: line1 line2"))

        let alphaIndex = message.range(of: "• alpha: ok")?.lowerBound
        let zetaIndex = message.range(of: "• zeta: line1 line2")?.lowerBound
        XCTAssertNotNil(alphaIndex)
        XCTAssertNotNil(zetaIndex)
        if let alphaIndex, let zetaIndex {
            XCTAssertLessThan(alphaIndex, zetaIndex)
        }
    }

    func testCustomEventWithoutDetailsOmitsDetailsSection() {
        let message = MessageBuilder.build(.custom(title: "Ping"), additional: "")

        XCTAssertTrue(message.contains("🧩 Ping"))
        XCTAssertFalse(message.contains("📋 Details:"))
    }

    func testFeedbackEventIncludesFeedbackLineAndCommonMetadata() {
        let message = MessageBuilder.build(.feedback(text: "App crashed on save"), additional: "QA")

        XCTAssertTrue(message.contains("📝 Feedback"))
        XCTAssertTrue(message.contains("📱 App:"))
        XCTAssertTrue(message.contains("📦 Version:"))
        XCTAssertTrue(message.contains("💬 User text: App crashed on save"))
    }

    func testFeedbackEventContainsFullExpectedMetadataLayout() {
        let message = MessageBuilder.build(.feedback(text: "Тут відбек"), additional: "🧘🏻‍♀️")

        XCTAssertTrue(message.contains("📝 Feedback"))
        XCTAssertTrue(message.contains("📱 App:"))
        XCTAssertTrue(message.contains("• 🧘🏻‍♀️"))
        XCTAssertTrue(message.contains("📦 Version:"))
        XCTAssertTrue(message.contains("🚚 Source:"))
        XCTAssertTrue(message.contains("📲 Device:"))
        XCTAssertTrue(message.contains("🧠 OS:"))
        XCTAssertTrue(message.contains("🌍 Locale:"))
        XCTAssertTrue(message.contains("🗺️ Region:"))
        XCTAssertTrue(message.contains("💬 User text: Тут відбек"))
    }

    func testFeedbackSharesSameBaseMetadataStructureAsFirstLaunch() {
        let firstLaunch = MessageBuilder.build(.firstLaunch, additional: "QA")
        let feedback = MessageBuilder.build(.feedback(text: "hello"), additional: "QA")

        for marker in [
            "📱 App:",
            "📦 Version:",
            "🚚 Source:",
            "📲 Device:",
            "🧠 OS:",
            "🌍 Locale:",
            "🗺️ Region:"
        ] {
            XCTAssertTrue(firstLaunch.contains(marker))
            XCTAssertTrue(feedback.contains(marker))
        }
        XCTAssertTrue(feedback.contains("💬 User text: hello"))
    }

    func testAppDidBecomeActiveIncludesExpectedHeader() {
        let message = MessageBuilder.build(.appDidBecomeActive, additional: "")

        XCTAssertTrue(message.contains("▶️ App Became Active"))
    }

    func testAdditionalWhitespaceIsTrimmedInAppLine() throws {
        let message = MessageBuilder.build(.firstLaunch, additional: "   QA Team  ")

        let lines = message.split(separator: "\n").map(String.init)
        guard let appLine = lines.first(where: { $0.hasPrefix("📱 App: ") }) else {
            return XCTFail("Missing app line")
        }

        XCTAssertTrue(appLine.contains(" • QA Team"))
        XCTAssertFalse(appLine.contains("  QA Team  "))
    }

    func testBlankAdditionalIsNotRenderedInAppLine() throws {
        let message = MessageBuilder.build(.firstLaunch, additional: "   \n\t ")

        let lines = message.split(separator: "\n").map(String.init)
        guard let appLine = lines.first(where: { $0.hasPrefix("📱 App: ") }) else {
            return XCTFail("Missing app line")
        }

        XCTAssertFalse(appLine.contains(" • "))
    }

    func testAppHashtagIsStableAndDerivedFromAppName() throws {
        let message = MessageBuilder.build(.firstLaunch, additional: "")

        let lines = message.split(separator: "\n").map(String.init)
        guard let appLine = lines.first(where: { $0.hasPrefix("📱 App: ") }) else {
            return XCTFail("Missing app line")
        }
        guard let hashtagLine = lines.last(where: { $0.hasPrefix("#") }) else {
            return XCTFail("Missing hashtag line")
        }

        let appName = String(appLine.dropFirst("📱 App: ".count))
        let expected = normalizedHashtag(from: appName)
        XCTAssertEqual(hashtagLine, "#\(expected)")
    }

    func testLocaleAndRegionMetadataHaveExpectedFormat() throws {
        let message = MessageBuilder.build(.firstLaunch, additional: "")

        let localePattern = #"\n🌍 Locale: .+\n"#
        XCTAssertNotNil(message.range(of: localePattern, options: .regularExpression))

        let regionPattern = #"\n🗺️ Region: .+ \((Unknown|[A-Za-z]{2,3})\)\n"#
        XCTAssertNotNil(message.range(of: regionPattern, options: .regularExpression))
    }

    func testStandardMetadataSectionsArePresent() {
        let message = MessageBuilder.build(.firstLaunch, additional: "")

        XCTAssertTrue(message.contains("📦 Version: "))
        XCTAssertTrue(message.contains("🚚 Source: "))
        XCTAssertTrue(message.contains("📲 Device: "))
        XCTAssertTrue(message.contains("🧠 OS: "))
    }

    func testAppNamePrefersDisplayName() {
        let name = MessageBuilder.appName(from: ["CFBundleDisplayName": "Display", "CFBundleName": "BundleName"])
        XCTAssertEqual(name, "Display")
    }

    func testAppNameFallsBackToBundleName() {
        let name = MessageBuilder.appName(from: ["CFBundleName": "BundleName"])
        XCTAssertEqual(name, "BundleName")
    }

    func testAppNameFallsBackToUnknownApp() {
        XCTAssertEqual(MessageBuilder.appName(from: nil), "Unknown App")
        XCTAssertEqual(MessageBuilder.appName(from: ["CFBundleDisplayName": "", "CFBundleName": ""]), "Unknown App")
    }

    func testCurrentRegionCodeUsesProvidedValue() {
        let code = MessageBuilder.currentRegionCode(regionIdentifier: "US")
        XCTAssertEqual(code, "US")
    }

    func testCurrentRegionCodeFallsBackToUnknownWhenMissing() {
        let code = MessageBuilder.currentRegionCode(regionIdentifier: nil)
        XCTAssertEqual(code, "Unknown")
    }

    private func normalizedHashtag(from appName: String) -> String {
        let words = appName
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined()

        return words.isEmpty ? "unknownapp" : words
    }
}
