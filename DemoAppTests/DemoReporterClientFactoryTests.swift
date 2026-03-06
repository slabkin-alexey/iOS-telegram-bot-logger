import XCTest
@testable import TelegramReporterDemo

final class DemoReporterClientFactoryTests: XCTestCase {
    func testFactoryReturnsMockClientWhenLaunchArgumentIsPresent() {
        let client = DemoReporterClientFactory.make(arguments: ["TelegramReporterDemo", "--use-mock-reporter"])

        XCTAssertTrue(client is MockDemoReporterClient)
    }

    func testFactoryReturnsLiveClientByDefault() {
        let client = DemoReporterClientFactory.make(arguments: ["TelegramReporterDemo"])

        XCTAssertTrue(client is LiveDemoReporterClient)
    }
}
