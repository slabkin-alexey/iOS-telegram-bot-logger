import Security
import XCTest
@testable import TelegramReporter

final class AccountInstallIdentityTests: XCTestCase {
    func testGetOrCreateReturnsExistingIDWhenStoredValueExists() throws {
        let result = try AccountInstallIdentity.getOrCreate(
            read: { _, _, _ in Data("existing-id".utf8) },
            upsert: { _, _, _, _ in XCTFail("upsert should not be called") },
            makeID: { XCTFail("makeID should not be called"); return "unused" }
        )

        XCTAssertEqual(result.id, "existing-id")
        XCTAssertFalse(result.isFirstForAccount)
    }

    func testGetOrCreateCreatesNewIDWhenNoStoredValue() throws {
        let capture = CaptureBox()

        let result = try AccountInstallIdentity.getOrCreate(
            read: { _, _, _ in nil },
            upsert: { data, service, account, synchronizable in
                capture.data = data
                capture.service = service
                capture.account = account
                capture.synchronizable = synchronizable
            },
            makeID: { "generated-id" }
        )

        XCTAssertEqual(result.id, "generated-id")
        XCTAssertTrue(result.isFirstForAccount)
        XCTAssertEqual(capture.data, Data("generated-id".utf8))
        XCTAssertEqual(capture.service, "com.melissun_team.accountInstall")
        XCTAssertEqual(capture.account, "account_install_id")
        XCTAssertEqual(capture.synchronizable, true)
    }

    func testGetOrCreateCreatesNewIDWhenStoredDataIsNotUTF8() throws {
        let result = try AccountInstallIdentity.getOrCreate(
            read: { _, _, _ in Data([0xFF, 0xFE, 0xFD]) },
            upsert: { _, _, _, _ in },
            makeID: { "fresh-id" }
        )

        XCTAssertEqual(result.id, "fresh-id")
        XCTAssertTrue(result.isFirstForAccount)
    }

    func testGetOrCreateCreatesNewIDWhenStoredValueIsEmpty() throws {
        let result = try AccountInstallIdentity.getOrCreate(
            read: { _, _, _ in Data("".utf8) },
            upsert: { _, _, _, _ in },
            makeID: { "fresh-id-2" }
        )

        XCTAssertEqual(result.id, "fresh-id-2")
        XCTAssertTrue(result.isFirstForAccount)
    }

    func testGetOrCreatePropagatesUpsertError() {
        XCTAssertThrowsError(
            try AccountInstallIdentity.getOrCreate(
                read: { _, _, _ in nil },
                upsert: { _, _, _, _ in throw TestError.failed },
                makeID: { "generated-id" }
            )
        ) { error in
            XCTAssertEqual(error as? TestError, .failed)
        }
    }

    func testIDFactoryReturnsNonEmptyIdentifier() {
        XCTAssertFalse(AccountInstallIdentity.idFactory().isEmpty)
    }

    func testKeychainReadReturnsNilForUnknownValue() {
        let service = "tests.service.\(UUID().uuidString)"
        let account = "tests.account.\(UUID().uuidString)"

        XCTAssertNil(AccountInstallIdentity.keychainRead(service: service, account: account, synchronizable: false))
    }

    func testKeychainUpsertCanBeInvokedDirectly() {
        let service = "tests.service.\(UUID().uuidString)"
        let account = "tests.account.\(UUID().uuidString)"

        do {
            try AccountInstallIdentity.keychainUpsert(
                data: Data("value".utf8),
                service: service,
                account: account,
                synchronizable: false
            )
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testInjectedKeychainUpsertStoresValue() throws {
        let storage = InMemoryKeychainSecurityClient()
        let client = storage.makeClient()
        let service = "tests.service.injected.\(UUID().uuidString)"
        let account = "tests.account.injected.\(UUID().uuidString)"

        try AccountInstallIdentity.keychainUpsert(
            data: Data("stored".utf8),
            service: service,
            account: account,
            synchronizable: false,
            client: client
        )

        let stored = KeychainStore.read(
            service: service,
            account: account,
            synchronizable: false,
            client: client
        )
        XCTAssertEqual(stored, Data("stored".utf8))
    }

    func testInjectedKeychainUpsertPropagatesClientError() {
        let client = KeychainSecurityClient(
            copyMatching: { _, _ in errSecSuccess },
            itemUpdate: { _, _ in errSecItemNotFound },
            itemAdd: { _, _ in errSecAuthFailed }
        )

        XCTAssertThrowsError(
            try AccountInstallIdentity.keychainUpsert(
                data: Data("stored".utf8),
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
