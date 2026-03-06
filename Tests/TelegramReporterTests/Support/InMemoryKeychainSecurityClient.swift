import Foundation
import Security
@testable import TelegramReporter

final class InMemoryKeychainSecurityClient: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: Data] = [:]

    func makeClient() -> KeychainSecurityClient {
        KeychainSecurityClient(
            copyMatching: { [self] query, result in
                let key = storageKey(from: query as NSDictionary)
                guard let data = readValue(for: key) else {
                    return errSecItemNotFound
                }
                result?.pointee = data as CFTypeRef
                return errSecSuccess
            },
            itemUpdate: { [self] query, attributes in
                let key = storageKey(from: query as NSDictionary)
                guard readValue(for: key) != nil else {
                    return errSecItemNotFound
                }
                guard let data = (attributes as NSDictionary)[kSecValueData as String] as? Data else {
                    return errSecParam
                }
                writeValue(data, for: key)
                return errSecSuccess
            },
            itemAdd: { [self] query, _ in
                let dictionary = query as NSDictionary
                let key = storageKey(from: dictionary)
                guard let data = dictionary[kSecValueData as String] as? Data else {
                    return errSecParam
                }
                writeValue(data, for: key)
                return errSecSuccess
            }
        )
    }

    private func storageKey(from dictionary: NSDictionary) -> String {
        let service = dictionary[kSecAttrService as String] as? String ?? ""
        let account = dictionary[kSecAttrAccount as String] as? String ?? ""
        return "\(service)|\(account)"
    }

    private func readValue(for key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return values[key]
    }

    private func writeValue(_ data: Data, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        values[key] = data
    }
}
