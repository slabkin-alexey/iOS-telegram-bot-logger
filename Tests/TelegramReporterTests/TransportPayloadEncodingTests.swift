import Foundation
import XCTest
@testable import TelegramReporter

final class TransportPayloadEncodingTests: XCTestCase {
    func testSendMessagePayloadEncodesExpectedCodingKeys() throws {
        let payload = TransportSendMessagePayload(
            chatID: "42",
            text: "Hello",
            disableWebPagePreview: true
        )

        let data = try JSONEncoder().encode(payload)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["chat_id"] as? String, "42")
        XCTAssertEqual(json["text"] as? String, "Hello")
        XCTAssertEqual(json["disable_web_page_preview"] as? Bool, true)
    }
}
