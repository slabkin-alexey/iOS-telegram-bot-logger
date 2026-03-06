import XCTest
import TelegramReporter
@testable import TelegramReporterDemo

final class SampleFeedbackImageFactoryTests: XCTestCase {
    func testFactoryProducesSupportedPngFeedbackImage() {
        let image = SampleFeedbackImageFactory.make()

        XCTAssertEqual(image.fileName, "demo-feedback.png")
        XCTAssertEqual(image.mimeType, "image/png")
        XCTAssertEqual(image.data, Data([0x89, 0x50, 0x4E, 0x47]))
    }
}
