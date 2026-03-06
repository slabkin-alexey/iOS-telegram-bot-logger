import XCTest
@testable import TelegramReporterDemo

final class DemoAccessibilityIDTests: XCTestCase {
    func testAccessibilityIdentifiersAreUniqueAndStable() {
        let identifiers = [
            DemoAccessibilityID.tokenField,
            DemoAccessibilityID.chatIDField,
            DemoAccessibilityID.additionalField,
            DemoAccessibilityID.customTitleField,
            DemoAccessibilityID.feedbackTextEditor,
            DemoAccessibilityID.attachImageButton,
            DemoAccessibilityID.clearImageButton,
            DemoAccessibilityID.sendStartButton,
            DemoAccessibilityID.sendCustomButton,
            DemoAccessibilityID.sendFeedbackButton,
            DemoAccessibilityID.imageStateLabel,
            DemoAccessibilityID.statusLabel
        ]

        XCTAssertEqual(Set(identifiers).count, identifiers.count)
        XCTAssertTrue(identifiers.allSatisfy { $0.hasPrefix("demo.") })
    }
}
