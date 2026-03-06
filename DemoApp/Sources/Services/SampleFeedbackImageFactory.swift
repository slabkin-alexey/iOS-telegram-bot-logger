import Foundation
import TelegramReporter

enum SampleFeedbackImageFactory {
    static func make() -> FeedbackImage {
        FeedbackImage(
            data: Data([0x89, 0x50, 0x4E, 0x47]),
            fileName: "demo-feedback.png",
            mimeType: "image/png"
        )!
    }
}
