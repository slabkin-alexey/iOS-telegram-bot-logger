import XCTest
@testable import TelegramReporterDemo

@MainActor
final class DemoScreenViewModelTests: XCTestCase {
    func testAttachAndClearSampleImageUpdatesState() {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())

        viewModel.attachSampleImage()
        XCTAssertTrue(viewModel.hasFeedbackImage)
        XCTAssertEqual(viewModel.feedbackImageDescription, L10n.tr("feedback.image.attached"))

        viewModel.clearFeedbackImage()
        XCTAssertFalse(viewModel.hasFeedbackImage)
        XCTAssertEqual(viewModel.feedbackImageDescription, L10n.tr("feedback.image.none"))
        XCTAssertEqual(viewModel.statusMessage, L10n.tr("status.ready"))
    }

    func testSendStartReportUpdatesSuccessStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())

        await viewModel.sendStartReport()

        XCTAssertFalse(viewModel.isError)
        XCTAssertEqual(viewModel.statusMessage, L10n.tr("status.start.success"))
    }

    func testSendCustomEventUpdatesSuccessStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())

        await viewModel.sendCustomEvent()

        XCTAssertFalse(viewModel.isError)
        XCTAssertEqual(viewModel.statusMessage, L10n.tr("status.custom.success"))
    }

    func testSendStartReportFailureUpdatesErrorStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())
        viewModel.token = "fail"

        await viewModel.sendStartReport()

        XCTAssertTrue(viewModel.isError)
        XCTAssertTrue(viewModel.statusMessage.hasPrefix(localizedFailurePrefix))
    }

    func testSendCustomEventFailureUpdatesErrorStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())
        viewModel.token = "fail"

        await viewModel.sendCustomEvent()

        XCTAssertTrue(viewModel.isError)
        XCTAssertTrue(viewModel.statusMessage.hasPrefix(localizedFailurePrefix))
    }

    func testSendFeedbackWithoutImageUpdatesSuccessStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())
        viewModel.feedbackText = "Need help"

        await viewModel.sendFeedback()

        XCTAssertFalse(viewModel.isError)
        XCTAssertEqual(viewModel.statusMessage, L10n.tr("status.feedback.success"))
    }

    func testSendFeedbackWithImageUpdatesSuccessStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())
        viewModel.feedbackText = "Need help"
        viewModel.attachSampleImage()

        await viewModel.sendFeedback()

        XCTAssertFalse(viewModel.isError)
        XCTAssertEqual(viewModel.statusMessage, L10n.tr("status.feedback.success_with_image"))
    }

    func testSendFeedbackFailureUpdatesErrorStatus() async {
        let viewModel = DemoScreenViewModel(client: MockDemoReporterClient())
        viewModel.token = "fail"
        viewModel.feedbackText = "Need help"

        await viewModel.sendFeedback()

        XCTAssertTrue(viewModel.isError)
        XCTAssertTrue(viewModel.statusMessage.hasPrefix(localizedFailurePrefix))
    }

    private var localizedFailurePrefix: String {
        L10n.tr("status.failure")
            .components(separatedBy: "%@")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
