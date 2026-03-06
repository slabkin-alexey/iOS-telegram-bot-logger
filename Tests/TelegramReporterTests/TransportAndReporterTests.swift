import XCTest
import Foundation
@testable import TelegramReporter

final class TransportAndReporterTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override class func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        URLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    override func tearDown() {
        URLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    func testTransportSendBuildsExpectedRequestPayload() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        try await Transport.send("Hello", using: Config(token: "abc123", chatID: "42"))

        guard let request = capturedRequest else {
            return XCTFail("Expected request to be captured")
        }

        XCTAssertEqual(request.url?.absoluteString, "https://api.telegram.org/botabc123/sendMessage")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testTransportSendWithAttachmentBuildsMultipartRequestPayload() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let attachment = Transport.Attachment(
            data: Data("abc".utf8),
            fileName: "image.png",
            mimeType: "image/png"
        )
        try await Transport.send("Feedback body", using: Config(token: "abc123", chatID: "42"), attachment: attachment)

        guard let request = capturedRequest else {
            return XCTFail("Expected request to be captured")
        }

        XCTAssertEqual(request.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertTrue((request.value(forHTTPHeaderField: "Content-Type") ?? "").contains("multipart/form-data"))
        XCTAssertTrue(request.httpBody != nil || request.httpBodyStream != nil)
    }

    func testTransportSendThrowsServerErrorForNon2xx() async {
        URLProtocolStub.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data("boom".utf8))
        }

        do {
            try await Transport.send("Hello", using: Config(token: "abc123", chatID: "42"))
            XCTFail("Expected send to throw")
        } catch let Transport.TransportError.serverError(statusCode, body) {
            XCTAssertEqual(statusCode, 500)
            XCTAssertEqual(body, "boom")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testTransportSendUsesFallbackBodyForNonUTF8ErrorResponse() async {
        URLProtocolStub.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 502, httpVersion: nil, headerFields: nil)!
            return (response, Data([0xFF, 0xFE, 0xFD]))
        }

        do {
            try await Transport.send("Hello", using: Config(token: "abc123", chatID: "42"))
            XCTFail("Expected send to throw")
        } catch let Transport.TransportError.serverError(statusCode, body) {
            XCTAssertEqual(statusCode, 502)
            XCTAssertEqual(body, "No response body")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testTransportSendThrowsInvalidResponseForNonHTTP() async {
        URLProtocolStub.requestHandler = { request in
            let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (response, Data())
        }

        do {
            try await Transport.send("Hello", using: Config(token: "abc123", chatID: "42"))
            XCTFail("Expected send to throw")
        } catch Transport.TransportError.invalidResponse {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testReporterReportSendsExpectedEventMessage() async {
        var requestCount = 0
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await TelegramReporter.report(.appDidBecomeActive, token: "abc123", chatID: "42", additional: "QA")

        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendMessage")
    }

    func testReporterReportSwallowsTransportFailure() async {
        var requestCount = 0

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data("fail".utf8))
        }

        await TelegramReporter.report(.custom(title: "Failure"), token: "abc123", chatID: "42", additional: "")

        XCTAssertEqual(requestCount, 1)
    }

    func testSendFeedbackWithImageUsesPhotoEndpoint() async throws {
        var capturedRequest: URLRequest?
        var requestCount = 0

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let imageURL = try makeTempImageURL(ext: "jpg")
        try await TelegramReporter.sendFeedback(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            text: "Need help",
            imageURL: imageURL
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
        XCTAssertEqual(requestCount, 1)
    }

    func testSendFeedbackWithoutImageUsesMessageEndpoint() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        try await TelegramReporter.sendFeedback(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            text: "Need help"
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendMessage")
    }

    func testSendFeedbackWithPickerImageUsesPhotoEndpoint() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let pickerImage = FeedbackImage(
            data: Data("picker-image".utf8),
            fileName: "picker.heic",
            mimeType: "image/heic"
        )

        try await TelegramReporter.sendFeedback(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            text: "From picker",
            feedbackImage: pickerImage
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
    }

    func testSendFeedbackSupportsImageFileURLAlias() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let imageURL = try makeTempImageURL(ext: "jpeg")
        try await TelegramReporter.sendFeedback(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            text: "Alias",
            imageFileURL: imageURL
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
    }

    func testSendCustomEventWithoutImageUsesMessageEndpoint() async {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await TelegramReporter.sendCustomEvent(
            token: "abc123",
            chatID: "42",
            title: "Custom",
            details: ["a": "b"],
            additional: "QA"
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendMessage")
    }

    func testSendCustomEventWithImageUsesPhotoEndpoint() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let imageURL = try makeTempImageURL(ext: "png")
        await TelegramReporter.sendCustomEvent(
            token: "abc123",
            chatID: "42",
            title: "Custom",
            details: [:],
            additional: "QA",
            imageFileURL: imageURL
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
    }

    func testSendCustomEventWithUnsupportedImageFallsBackToMessageEndpoint() async throws {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let imageURL = try makeTempImageURL(ext: "gif")
        await TelegramReporter.sendCustomEvent(
            token: "abc123",
            chatID: "42",
            title: "Custom",
            details: [:],
            additional: "QA",
            imageFileURL: imageURL
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendMessage")
    }

    func testReportFeedbackEventWithEmbeddedImageUsesPhotoEndpoint() async {
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let embeddedImage = FeedbackImage(
            data: Data("embedded".utf8),
            fileName: "embedded.png",
            mimeType: "image/png"
        )

        await TelegramReporter.report(
            .feedback(text: "Embedded", image: embeddedImage),
            token: "abc123",
            chatID: "42",
            additional: "QA"
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
    }

    func testSendFeedbackRejectsEmptyMessage() async {
        do {
            try await TelegramReporter.sendFeedback(
                token: "abc123",
                chatID: "42",
                additional: "QA",
                text: "   \n\t "
            )
            XCTFail("Expected empty feedback to throw")
        } catch TelegramReporter.FeedbackError.emptyMessage {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSendFeedbackTrimsMessageAndUsesSinglePhotoRequest() async throws {
        var capturedRequest: URLRequest?
        var requestCount = 0

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let imageURL = try makeTempImageURL(ext: "jpg")
        try await TelegramReporter.sendFeedback(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            text: "  hello from sender  ",
            imageURL: imageURL
        )

        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendPhoto")
        XCTAssertEqual(requestCount, 1)
    }

    func testStartLogReportWithIgnoreFirstLaunchSendsMessage() async {
        var requestCount = 0
        var capturedRequest: URLRequest?

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await TelegramReporter.startLogReport(token: "abc123", chatID: "42", additional: "QA", ignoreFirstLaunch: true)

        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.telegram.org/botabc123/sendMessage")
    }

    func testStartLogReportWithoutIgnoreDoesNotCrashAndSendsAtMostOnce() async {
        var requestCount = 0

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await TelegramReporter.startLogReport(token: "abc123", chatID: "42", additional: "QA", ignoreFirstLaunch: false)

        XCTAssertLessThanOrEqual(requestCount, 1)
    }

    func testStartLogReportInjectedReportsWhenFirstForAccount() async {
        var reported = false
        await TelegramReporter.startLogReport(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: { ("id-1", true) },
            reportFirstLaunch: { token, chatID, additional in
                reported = true
                XCTAssertEqual(token, "abc123")
                XCTAssertEqual(chatID, "42")
                XCTAssertEqual(additional, "QA")
            }
        )

        XCTAssertTrue(reported)
    }

    func testStartLogReportInjectedSkipsWhenNotFirstForAccount() async {
        var reported = false
        await TelegramReporter.startLogReport(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: { ("id-1", false) },
            reportFirstLaunch: { _, _, _ in reported = true }
        )

        XCTAssertFalse(reported)
    }

    func testStartLogReportInjectedSwallowsIdentityError() async {
        var reported = false

        await TelegramReporter.startLogReport(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: { throw TestError.failed },
            reportFirstLaunch: { _, _, _ in reported = true }
        )

        XCTAssertFalse(reported)
    }

    private func makeTempImageURL(ext: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
        try Data([0xFF, 0xD8, 0xFF]).write(to: url)
        return url
    }
}
