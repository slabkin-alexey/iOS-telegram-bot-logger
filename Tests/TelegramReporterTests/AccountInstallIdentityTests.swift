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
        var capturedData: Data?
        var capturedService: String?
        var capturedAccount: String?
        var capturedSync: Bool?

        let result = try AccountInstallIdentity.getOrCreate(
            read: { _, _, _ in nil },
            upsert: { data, service, account, synchronizable in
                capturedData = data
                capturedService = service
                capturedAccount = account
                capturedSync = synchronizable
            },
            makeID: { "generated-id" }
        )

        XCTAssertEqual(result.id, "generated-id")
        XCTAssertTrue(result.isFirstForAccount)
        XCTAssertEqual(capturedData, Data("generated-id".utf8))
        XCTAssertEqual(capturedService, "com.melissun_team.accountInstall")
        XCTAssertEqual(capturedAccount, "account_install_id")
        XCTAssertEqual(capturedSync, true)
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
        enum DummyError: Error { case failed }

        XCTAssertThrowsError(
            try AccountInstallIdentity.getOrCreate(
                read: { _, _, _ in nil },
                upsert: { _, _, _, _ in throw DummyError.failed },
                makeID: { "generated-id" }
            )
        ) { error in
            XCTAssertTrue(error is DummyError)
        }
    }
}
