import XCTest
import Foundation
@testable import TelegramReporter

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

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
        enum DummyError: Error { case failed }
        var reported = false

        await TelegramReporter.startLogReport(
            token: "abc123",
            chatID: "42",
            additional: "QA",
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: { throw DummyError.failed },
            reportFirstLaunch: { _, _, _ in reported = true }
        )

        XCTAssertFalse(reported)
    }
}
