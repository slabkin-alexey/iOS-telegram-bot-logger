import XCTest
@testable import TelegramReporter

final class InstallIdentityServiceTests: XCTestCase {
    func testShouldSendFirstLaunchReturnsTrueWhenIgnored() async throws {
        let shouldSend = try await InstallIdentityService.shouldSendFirstLaunch(
            ignoreFirstLaunch: true,
            getOrCreateInstallIdentity: { XCTFail("Should not be called"); return ("unused", false) }
        )

        XCTAssertTrue(shouldSend)
    }

    func testShouldSendFirstLaunchReturnsTrueForFirstAccountInstall() async throws {
        let shouldSend = try await InstallIdentityService.shouldSendFirstLaunch(
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: { ("id", true) }
        )

        XCTAssertTrue(shouldSend)
    }

    func testShouldSendFirstLaunchReturnsFalseForExistingAccountInstall() async throws {
        let shouldSend = try await InstallIdentityService.shouldSendFirstLaunch(
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: { ("id", false) }
        )

        XCTAssertFalse(shouldSend)
    }

    @MainActor
    func testShouldSendFirstLaunchPerformsIdentityLookupOffMainThread() async throws {
        let expectation = expectation(description: "background lookup")

        let shouldSend = try await InstallIdentityService.shouldSendFirstLaunch(
            ignoreFirstLaunch: false,
            getOrCreateInstallIdentity: {
                XCTAssertFalse(Thread.isMainThread)
                expectation.fulfill()
                return ("id", true)
            }
        )

        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(shouldSend)
    }

    func testShouldSendFirstLaunchPropagatesLookupError() async {
        do {
            _ = try await InstallIdentityService.shouldSendFirstLaunch(
                ignoreFirstLaunch: false,
                getOrCreateInstallIdentity: { throw TestError.failed }
            )
            XCTFail("Expected lookup to throw")
        } catch let error as TestError {
            XCTAssertEqual(error, .failed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
