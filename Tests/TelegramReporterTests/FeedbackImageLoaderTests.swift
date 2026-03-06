import Foundation
import XCTest
@testable import TelegramReporter

final class FeedbackImageLoaderTests: XCTestCase {
    func testPrepareFeedbackImageReturnsNilWhenURLIsMissing() async {
        let image = await FeedbackImageLoader.prepareFeedbackImage(from: nil)

        XCTAssertNil(image)
    }

    func testPrepareFeedbackImageRejectsUnsupportedExtension() async throws {
        let imageURL = try makeTempImageURL(ext: "gif")
        let image = await FeedbackImageLoader.prepareFeedbackImage(from: imageURL)

        XCTAssertNil(image)
    }

    func testPrepareFeedbackImageReturnsNilWhenReadFails() async throws {
        let imageURL = try makeTempImageURL(ext: "jpg")

        let image = await FeedbackImageLoader.prepareFeedbackImage(
            from: imageURL,
            loadData: { _ in throw TestError.failed }
        )

        XCTAssertNil(image)
    }

    @MainActor
    func testPrepareFeedbackImageLoadsDataOffMainThread() async throws {
        let imageURL = try makeTempImageURL(ext: "jpeg")
        let expectation = expectation(description: "background read")

        let image = await FeedbackImageLoader.prepareFeedbackImage(
            from: imageURL,
            loadData: { _ in
                XCTAssertFalse(Thread.isMainThread)
                expectation.fulfill()
                return Data("image".utf8)
            }
        )

        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertEqual(image?.fileName, imageURL.lastPathComponent)
        XCTAssertEqual(image?.mimeType, "image/jpeg")
        XCTAssertEqual(image?.data, Data("image".utf8))
    }

    func testPrepareImageAttachmentBuildsTransportAttachment() async throws {
        let imageURL = try makeTempImageURL(ext: "png")

        let attachment = await FeedbackImageLoader.prepareImageAttachment(
            from: imageURL,
            loadData: { _ in Data("payload".utf8) }
        )

        XCTAssertEqual(attachment?.fileName, imageURL.lastPathComponent)
        XCTAssertEqual(attachment?.mimeType, "image/png")
        XCTAssertEqual(attachment?.data, Data("payload".utf8))
    }

    private func makeTempImageURL(ext: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
        try Data("seed".utf8).write(to: url)
        return url
    }
}
