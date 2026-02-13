import XCTest
@testable import TelegramReporter

final class TransportErrorTests: XCTestCase {
    func testInvalidResponseDescription() {
        let description = Transport.TransportError.invalidResponse.errorDescription
        XCTAssertEqual(description, "Invalid HTTP response from Telegram API")
    }

    func testServerErrorDescriptionIncludesStatusAndBody() {
        let description = Transport.TransportError
            .serverError(statusCode: 401, body: "Unauthorized")
            .errorDescription

        XCTAssertEqual(description, "Telegram API error (HTTP 401): Unauthorized")
    }
}
