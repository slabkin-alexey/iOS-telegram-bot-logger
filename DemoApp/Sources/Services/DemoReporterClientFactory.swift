import Foundation

enum DemoReporterClientFactory {
    static func make(arguments: [String] = ProcessInfo.processInfo.arguments) -> any DemoReporterClient {
        if arguments.contains("--use-mock-reporter") {
            return MockDemoReporterClient()
        }

        return LiveDemoReporterClient()
    }
}
