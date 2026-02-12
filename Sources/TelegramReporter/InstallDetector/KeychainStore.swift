//
//  KeychainStore.swift
//

import Foundation
import Security

enum KeychainStore {
    private static func secBool(_ value: Bool) -> CFBoolean {
        value ? kCFBooleanTrue : kCFBooleanFalse
    }

    static func read(service: String, account: String, synchronizable: Bool) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: secBool(synchronizable),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    static func upsert(_ data: Data,
                       service: String,
                       account: String,
                       synchronizable: Bool) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: secBool(synchronizable)
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError.osStatus(addStatus) }
        } else if status != errSecSuccess {
            throw KeychainError.osStatus(status)
        }
    }

    enum KeychainError: Error { case osStatus(OSStatus) }
}
