import XCTest
import TelegramReporter
@testable import TelegramReporterDemo

final class LiveDemoReporterClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocol.registerClass(DemoURLProtocolStub.self)
    }

    override class func tearDown() {
        URLProtocol.unregisterClass(DemoURLProtocolStub.self)
        DemoURLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    override func tearDown() {
        DemoURLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    func testDefaultStartReportRoutesThroughTelegramReporter() async throws {
        let capture = RequestCaptureBox()
        DemoURLProtocolStub.requestHandler = { request in
            capture.request = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        try await LiveDemoReporterClient().sendStartReport(token: "token", chatID: "42", additional: "Demo")

        XCTAssertEqual(capture.request?.url?.absoluteString, "https://api.telegram.org/bottoken/sendMessage")
    }

    func testDefaultCustomEventRoutesThroughTelegramReporter() async throws {
        let capture = RequestCaptureBox()
        DemoURLProtocolStub.requestHandler = { request in
            capture.request = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        try await LiveDemoReporterClient().sendCustomEvent(
            token: "token",
            chatID: "42",
            title: "Demo Event",
            details: ["Build": "1.1"],
            additional: "Demo"
        )

        XCTAssertEqual(capture.request?.url?.absoluteString, "https://api.telegram.org/bottoken/sendMessage")
    }

    func testDefaultFeedbackRoutesThroughTelegramReporter() async throws {
        let capture = RequestCaptureBox()
        DemoURLProtocolStub.requestHandler = { request in
            capture.request = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        try await LiveDemoReporterClient().sendFeedback(
            token: "token",
            chatID: "42",
            additional: "Demo",
            text: "App feels great",
            image: FeedbackImage(data: Data("image".utf8), fileName: "feedback.png", mimeType: "image/png")
        )

        XCTAssertEqual(capture.request?.url?.absoluteString, "https://api.telegram.org/bottoken/sendPhoto")
    }

    func testInjectedHandlersReceiveOriginalArguments() async throws {
        guard let expectedImage = FeedbackImage(data: Data("picker".utf8), fileName: "picker.heic", mimeType: "image/heic") else {
            return XCTFail("Expected valid feedback image")
        }

        let box = LiveDemoReporterClientInvocationBox()
        let client = LiveDemoReporterClient(
            startReportHandler: { token, chatID, additional in
                box.start = (token, chatID, additional)
            },
            customEventHandler: { token, chatID, title, details, additional in
                box.custom = (token, chatID, title, details, additional)
            },
            feedbackHandler: { token, chatID, additional, text, image in
                box.feedback = (token, chatID, additional, text, image)
            }
        )

        try await client.sendStartReport(token: "token", chatID: "42", additional: "Demo")
        try await client.sendCustomEvent(
            token: "token",
            chatID: "42",
            title: "Release",
            details: ["Build": "1.1"],
            additional: "Demo"
        )
        try await client.sendFeedback(
            token: "token",
            chatID: "42",
            additional: "Demo",
            text: "User note",
            image: expectedImage
        )

        XCTAssertEqual(box.start?.0, "token")
        XCTAssertEqual(box.start?.1, "42")
        XCTAssertEqual(box.start?.2, "Demo")
        XCTAssertEqual(box.custom?.0, "token")
        XCTAssertEqual(box.custom?.1, "42")
        XCTAssertEqual(box.custom?.2, "Release")
        XCTAssertEqual(box.custom?.3, ["Build": "1.1"])
        XCTAssertEqual(box.custom?.4, "Demo")
        XCTAssertEqual(box.feedback?.0, "token")
        XCTAssertEqual(box.feedback?.1, "42")
        XCTAssertEqual(box.feedback?.2, "Demo")
        XCTAssertEqual(box.feedback?.3, "User note")
        XCTAssertEqual(box.feedback?.4?.fileName, expectedImage.fileName)
    }
}
