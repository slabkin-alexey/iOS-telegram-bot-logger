import XCTest
import Security
@testable import TelegramReporter

final class AccountInstallIdentityTests: XCTestCase {
    func testGetOrCreateReturnsIDOrMissingEntitlementError() {
        do {
            let result = try AccountInstallIdentity.getOrCreate()
            XCTAssertFalse(result.id.isEmpty)
        } catch let KeychainStore.KeychainError.osStatus(status) {
            XCTAssertEqual(status, errSecMissingEntitlement)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
