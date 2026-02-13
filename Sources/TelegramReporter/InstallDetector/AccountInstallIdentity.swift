//
//  AccountInstallIdentity.swift
//

import Foundation

enum AccountInstallIdentity {
    private static let service = "com.melissun_team.accountInstall"
    private static let account = "account_install_id"

    static func getOrCreate(
        read: (_ service: String, _ account: String, _ synchronizable: Bool) -> Data? = { service, account, synchronizable in
            KeychainStore.read(service: service, account: account, synchronizable: synchronizable)
        },
        upsert: (_ data: Data, _ service: String, _ account: String, _ synchronizable: Bool) throws -> Void = { data, service, account, synchronizable in
            try KeychainStore.upsert(data, service: service, account: account, synchronizable: synchronizable)
        },
        makeID: () -> String = { UUID().uuidString }
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
