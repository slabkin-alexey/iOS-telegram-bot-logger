import XCTest
@testable import TelegramReporterDemo

final class CustomDetailsParserTests: XCTestCase {
    func testDefaultDetailsMatchExpectedPayload() {
        XCTAssertEqual(
            CustomDetailsParser.defaultDetails(),
            [
                "channel": "demo-app",
                "surface": "manual-trigger"
            ]
        )
    }
}
