//
//  KeychainStore.swift
//

import Foundation
import Security

enum KeychainStore {
    private static func secBoolean(_ value: Bool) -> CFBoolean {
        value ? kCFBooleanTrue : kCFBooleanFalse
    }

    static func read(service: String, account: String, synchronizable: Bool) -> Data? {
        ReporterLogger.log(
            "KeychainStore.read",
            "Reading keychain item for service=\(service), account=\(account), synchronizable=\(synchronizable)"
        )
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: secBoolean(synchronizable),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            ReporterLogger.log("KeychainStore.read", "Read failed with status=\(status)")
            return nil
        }
        ReporterLogger.log("KeychainStore.read", "Read succeeded")
        return item as? Data
    }

    static func upsert(_ data: Data,
                       service: String,
                       account: String,
                       synchronizable: Bool) throws {
        ReporterLogger.log(
            "KeychainStore.upsert",
            "Upserting keychain item for service=\(service), account=\(account), synchronizable=\(synchronizable), dataLength=\(data.count)"
        )
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: secBoolean(synchronizable)
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            ReporterLogger.log("KeychainStore.upsert", "Item not found, performing add")
            var addQuery = query
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                ReporterLogger.log("KeychainStore.upsert", "Add failed with status=\(addStatus)")
                throw KeychainError.osStatus(addStatus)
            }
            ReporterLogger.log("KeychainStore.upsert", "Add succeeded")
        } else if status != errSecSuccess {
            ReporterLogger.log("KeychainStore.upsert", "Update failed with status=\(status)")
            throw KeychainError.osStatus(status)
        } else {
            ReporterLogger.log("KeychainStore.upsert", "Update succeeded")
        }
    }

    enum KeychainError: Error { case osStatus(OSStatus) }
}
