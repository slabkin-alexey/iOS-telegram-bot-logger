import XCTest
import TelegramReporter
@testable import TelegramReporterDemo

final class MockDemoReporterClientTests: XCTestCase {
    func testStartReportThrowsSimulatedFailureForFailToken() async {
        let client = MockDemoReporterClient()

        do {
            try await client.sendStartReport(token: "fail", chatID: "chat", additional: "Demo")
            XCTFail("Expected simulated failure")
        } catch let error as DemoReporterClientError {
            XCTAssertEqual(error, .simulatedFailure)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCustomEventSucceedsForRegularToken() async throws {
        let client = MockDemoReporterClient()

        try await client.sendCustomEvent(
            token: "ok",
            chatID: "chat",
            title: "Demo",
            details: CustomDetailsParser.defaultDetails(),
            additional: "Demo"
        )
    }

    func testFeedbackRejectsEmptyText() async {
        let client = MockDemoReporterClient()

        do {
            try await client.sendFeedback(
                token: "ok",
                chatID: "chat",
                additional: "Demo",
                text: " \n\t ",
                image: nil
            )
            XCTFail("Expected empty feedback to fail")
        } catch TelegramReporter.FeedbackError.emptyMessage {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
