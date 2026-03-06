import XCTest
@testable import TelegramReporter

final class ReportViewModelTests: XCTestCase {
    func testAttachmentIsNilForNonFeedbackEvents() {
        let viewModel = ReportViewModel(event: .firstLaunch, additional: "QA")

        XCTAssertNil(viewModel.attachment)
    }

    func testAttachmentIsNilForFeedbackWithoutImage() {
        let viewModel = ReportViewModel(event: .feedback(text: "Text", image: nil), additional: "QA")

        XCTAssertNil(viewModel.attachment)
    }

    func testAttachmentUsesEmbeddedFeedbackImage() {
        let image = FeedbackImage(data: Data("image".utf8), fileName: "feedback.jpg", mimeType: "image/jpeg")
        let viewModel = ReportViewModel(event: .feedback(text: "Text", image: image), additional: "QA")

        XCTAssertEqual(viewModel.attachment?.fileName, "feedback.jpg")
        XCTAssertEqual(viewModel.attachment?.mimeType, "image/jpeg")
        XCTAssertEqual(viewModel.attachment?.data, Data("image".utf8))
    }
}
