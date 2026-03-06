import Foundation
import Security

enum KeychainStoreError: Error, Equatable {
    case osStatus(OSStatus)
}
