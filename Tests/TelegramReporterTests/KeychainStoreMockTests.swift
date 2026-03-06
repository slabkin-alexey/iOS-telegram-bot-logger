import Foundation
import Security
import XCTest
@testable import TelegramReporter

final class KeychainStoreMockTests: XCTestCase {
    func testReadReturnsDataWhenSecurityClientSucceeds() {
        let expectedData = Data("payload".utf8)
        let client = KeychainSecurityClient(
            copyMatching: { _, itemPointer in
                itemPointer?.pointee = expectedData as CFData
                return errSecSuccess
            },
            itemUpdate: { _, _ in errSecSuccess },
            itemAdd: { _, _ in errSecSuccess }
        )

        let data = KeychainStore.read(
            service: "service",
            account: "account",
            synchronizable: true,
            client: client
        )

        XCTAssertEqual(data, expectedData)
    }

    func testUpsertThrowsWhenAddFails() {
        let client = KeychainSecurityClient(
            copyMatching: { _, _ in errSecSuccess },
            itemUpdate: { _, _ in errSecItemNotFound },
            itemAdd: { _, _ in errSecAuthFailed }
        )

        XCTAssertThrowsError(
            try KeychainStore.upsert(
                Data("payload".utf8),
                service: "service",
                account: "account",
                synchronizable: false,
                client: client
            )
        ) { error in
            XCTAssertEqual(error as? KeychainStoreError, .osStatus(errSecAuthFailed))
        }
    }

    func testUpsertThrowsWhenUpdateFails() {
        let client = KeychainSecurityClient(
            copyMatching: { _, _ in errSecSuccess },
            itemUpdate: { _, _ in errSecAuthFailed },
            itemAdd: { _, _ in errSecSuccess }
        )

        XCTAssertThrowsError(
            try KeychainStore.upsert(
                Data("payload".utf8),
                service: "service",
                account: "account",
                synchronizable: false,
                client: client
            )
        ) { error in
            XCTAssertEqual(error as? KeychainStoreError, .osStatus(errSecAuthFailed))
        }
    }
}
