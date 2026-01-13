//
//  AccountInstallIdentity.swift
//

import Foundation

enum AccountInstallIdentity {
    private static let service = "com.melissun_team.accountInstall"
    private static let account = "account_install_id"

    static func getOrCreate() throws -> (id: String, isFirstForAccount: Bool) {
        if let data = KeychainStore.read(service: service, account: account, synchronizable: true),
           let existing = String(data: data, encoding: .utf8),
           !existing.isEmpty {
            return (existing, false)
        }

        let newID = UUID().uuidString
        try KeychainStore.upsert(Data(newID.utf8),
                                 service: service,
                                 account: account,
                                 synchronizable: true)
        return (newID, true)
    }
}
