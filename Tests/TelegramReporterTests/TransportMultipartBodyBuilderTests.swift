import Foundation
import XCTest
@testable import TelegramReporter

final class TransportMultipartBodyBuilderTests: XCTestCase {
    func testBuildContainsTextAndFileFields() throws {
        var builder = TransportMultipartBodyBuilder(boundary: "Boundary")
        let attachment = TransportAttachment(
            data: Data("image".utf8),
            fileName: "shot.png",
            mimeType: "image/png"
        )

        builder.addTextField(name: "chat_id", value: "42")
        builder.addTextField(name: "caption", value: "Hello")
        builder.addFileField(name: "photo", attachment: attachment)
        builder.finalize()

        let result = try XCTUnwrap(String(data: builder.build(), encoding: .utf8))

        XCTAssertTrue(result.contains("name=\"chat_id\""))
        XCTAssertTrue(result.contains("42"))
        XCTAssertTrue(result.contains("name=\"caption\""))
        XCTAssertTrue(result.contains("Hello"))
        XCTAssertTrue(result.contains("name=\"photo\"; filename=\"shot.png\""))
        XCTAssertTrue(result.contains("Content-Type: image/png"))
        XCTAssertTrue(result.contains("image"))
        XCTAssertTrue(result.contains("--Boundary--"))
    }
}
