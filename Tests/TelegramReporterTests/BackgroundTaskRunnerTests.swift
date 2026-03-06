import XCTest
@testable import TelegramReporter

final class BackgroundTaskRunnerTests: XCTestCase {
    func testRunReturnsValue() async throws {
        let value = try await BackgroundTaskRunner.run {
            42
        }

        XCTAssertEqual(value, 42)
    }

    func testRunPropagatesError() async {
        do {
            _ = try await BackgroundTaskRunner.run {
                throw TestError.failed
            }
            XCTFail("Expected run to throw")
        } catch let error as TestError {
            XCTAssertEqual(error, .failed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
