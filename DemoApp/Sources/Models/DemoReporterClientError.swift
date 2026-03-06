import Foundation

enum DemoReporterClientError: LocalizedError, Equatable {
    case simulatedFailure

    var errorDescription: String? {
        "Simulated reporter failure."
    }
}
