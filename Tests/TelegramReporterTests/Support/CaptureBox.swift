import Foundation

final class CaptureBox: @unchecked Sendable {
    var data: Data?
    var service: String?
    var account: String?
    var synchronizable: Bool?
}
