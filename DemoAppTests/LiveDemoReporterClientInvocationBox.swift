import TelegramReporter

final class LiveDemoReporterClientInvocationBox: @unchecked Sendable {
    var start: (String, String, String)?
    var custom: (String, String, String, [String: String], String)?
    var feedback: (String, String, String, String, FeedbackImage?)?
}
