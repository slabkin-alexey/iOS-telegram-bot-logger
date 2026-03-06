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

    func testFeedbackImageLowercasesMimeType() {
        let image = FeedbackImage(data: Data("img".utf8), fileName: "picker.heic", mimeType: "IMAGE/HEIC")

        XCTAssertEqual(image?.mimeType, "image/heic")
    }

    func testMimeTypeForFileExtensionSupportsAllKnownFormats() {
        XCTAssertEqual(FeedbackImage.mimeType(forFileExtension: "png"), "image/png")
        XCTAssertEqual(FeedbackImage.mimeType(forFileExtension: "jpg"), "image/jpeg")
        XCTAssertEqual(FeedbackImage.mimeType(forFileExtension: "jpeg"), "image/jpeg")
        XCTAssertEqual(FeedbackImage.mimeType(forFileExtension: "heic"), "image/heic")
    }

    func testMimeTypeForFileExtensionRejectsUnknownValue() {
        XCTAssertNil(FeedbackImage.mimeType(forFileExtension: "bmp"))
    }
}
