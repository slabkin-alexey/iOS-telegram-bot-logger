//
//  AccountInstallIdentity.swift
//

import Foundation

enum AccountInstallIdentity {
    typealias ReadClosure = @Sendable (_ service: String, _ account: String, _ synchronizable: Bool) -> Data?
    typealias UpsertClosure = @Sendable (_ data: Data, _ service: String, _ account: String, _ synchronizable: Bool) throws -> Void
    typealias MakeIDClosure = @Sendable () -> String

    private static let service = "com.melissun_team.accountInstall"
    private static let account = "account_install_id"

    static func keychainRead(service: String, account: String, synchronizable: Bool) -> Data? {
        KeychainStore.read(service: service, account: account, synchronizable: synchronizable)
    }

    static func keychainUpsert(data: Data, service: String, account: String, synchronizable: Bool) throws {
        try keychainUpsert(
            data: data,
            service: service,
            account: account,
            synchronizable: synchronizable,
            client: .live
        )
    }

    static func keychainUpsert(
        data: Data,
        service: String,
        account: String,
        synchronizable: Bool,
        client: KeychainSecurityClient
    ) throws {
        try KeychainStore.upsert(
            data,
            service: service,
            account: account,
            synchronizable: synchronizable,
            client: client
        )
    }

    static func idFactory() -> String {
        UUID().uuidString
    }

    static func getOrCreate(
        read: ReadClosure = keychainRead,
        upsert: UpsertClosure = keychainUpsert,
        makeID: MakeIDClosure = idFactory
    ) throws -> (id: String, isFirstForAccount: Bool) {
        ReporterLogger.log("AccountInstallIdentity.getOrCreate", "Attempting to read account install identity")
        if let data = read(service, account, true),
           let existing = String(data: data, encoding: .utf8),
           !existing.isEmpty {
            ReporterLogger.log("AccountInstallIdentity.getOrCreate", "Using existing install identity")
            return (existing, false)
        }

        let newID = makeID()
        ReporterLogger.log("AccountInstallIdentity.getOrCreate", "No valid identity found, creating a new one")
        try upsert(Data(newID.utf8), service, account, true)
        ReporterLogger.log("AccountInstallIdentity.getOrCreate", "New install identity stored successfully")
        return (newID, true)
    }
}
