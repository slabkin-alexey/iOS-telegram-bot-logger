//
//  FeedbackImage.swift
//

import Foundation

public struct FeedbackImage: Sendable {
    public let data: Data
    public let fileName: String
    public let mimeType: String

    public init?(data: Data, fileName: String, mimeType: String) {
        guard Self.supportedMimeTypes.contains(mimeType.lowercased()) else { return nil }
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType.lowercased()
    }

    static let supportedMimeTypes: Set<String> = [
        "image/png",
        "image/heic",
        "image/jpeg"
    ]

    static func mimeType(forFileExtension fileExtension: String) -> String? {
        switch fileExtension.lowercased() {
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "heic":
            return "image/heic"
        default:
            return nil
        }
    }
}
