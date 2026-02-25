import XCTest
@testable import TelegramReporter

final class FeedbackImageTests: XCTestCase {
    func testFeedbackImageAcceptsSupportedMimeType() {
        let image = FeedbackImage(data: Data("img".utf8), fileName: "picker.jpg", mimeType: "image/jpeg")
        XCTAssertNotNil(image)
    }

    func testFeedbackImageRejectsUnsupportedMimeType() {
        let image = FeedbackImage(data: Data("img".utf8), fileName: "picker.gif", mimeType: "image/gif")
        XCTAssertNil(image)
    }
}
