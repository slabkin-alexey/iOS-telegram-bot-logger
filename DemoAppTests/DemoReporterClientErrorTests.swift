import XCTest
@testable import TelegramReporterDemo

final class DemoReporterClientErrorTests: XCTestCase {
    func testSimulatedFailureHasLocalizedDescription() {
        XCTAssertEqual(DemoReporterClientError.simulatedFailure.errorDescription, "Simulated reporter failure.")
        XCTAssertEqual(DemoReporterClientError.simulatedFailure.localizedDescription, "Simulated reporter failure.")
    }
}
