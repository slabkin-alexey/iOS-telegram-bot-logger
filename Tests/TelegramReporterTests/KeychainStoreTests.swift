import XCTest
@testable import TelegramReporter

final class KeychainStoreTests: XCTestCase {
    func testUpsertThenReadReturnsStoredData() throws {
        let client = InMemoryKeychainSecurityClient().makeClient()
        let service = "tests.service.\(UUID().uuidString)"
        let account = "tests.account.\(UUID().uuidString)"
        let data = Data("first".utf8)

        try KeychainStore.upsert(data, service: service, account: account, synchronizable: false, client: client)
        let stored = KeychainStore.read(service: service, account: account, synchronizable: false, client: client)

        XCTAssertEqual(stored, data)
    }

    func testUpsertUpdatesExistingValue() throws {
        let client = InMemoryKeychainSecurityClient().makeClient()
        let service = "tests.service.\(UUID().uuidString)"
        let account = "tests.account.\(UUID().uuidString)"

        try KeychainStore.upsert(Data("first".utf8), service: service, account: account, synchronizable: false, client: client)
        try KeychainStore.upsert(Data("second".utf8), service: service, account: account, synchronizable: false, client: client)
        let stored = KeychainStore.read(service: service, account: account, synchronizable: false, client: client)

        XCTAssertEqual(stored, Data("second".utf8))
    }

    func testReadMissingValueReturnsNil() {
        let client = InMemoryKeychainSecurityClient().makeClient()
        let service = "tests.service.\(UUID().uuidString)"
        let account = "tests.account.\(UUID().uuidString)"

        let stored = KeychainStore.read(service: service, account: account, synchronizable: false, client: client)

        XCTAssertNil(stored)
    }
}
