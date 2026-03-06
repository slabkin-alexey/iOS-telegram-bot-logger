import XCTest
@testable import TelegramReporter

final class TelegramReporterEventTests: XCTestCase {
    func testLogNameCoversAllCases() {
        let firstLaunch = TelegramReporterEvent.firstLaunch
        let active = TelegramReporterEvent.appDidBecomeActive
        let custom = TelegramReporterEvent.custom(title: "Sync", details: ["a": "b"])
        let feedback = TelegramReporterEvent.feedback(text: "hello", image: FeedbackImage(data: Data("a".utf8), fileName: "a.png", mimeType: "image/png"))

        XCTAssertEqual(firstLaunch.logName, "firstLaunch")
        XCTAssertEqual(active.logName, "appDidBecomeActive")
        XCTAssertEqual(custom.logName, "custom(title: Sync, detailsCount: 1)")
        XCTAssertEqual(feedback.logName, "feedback(textLength: 5, hasImage: true)")
    }
}
