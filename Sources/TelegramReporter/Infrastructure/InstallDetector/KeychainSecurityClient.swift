import Foundation
import Security

struct KeychainSecurityClient {
    let copyMatching: @Sendable (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    let itemUpdate: @Sendable (CFDictionary, CFDictionary) -> OSStatus
    let itemAdd: @Sendable (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus

    static let live = KeychainSecurityClient(
        copyMatching: SecItemCopyMatching,
        itemUpdate: SecItemUpdate,
        itemAdd: SecItemAdd
    )
}
