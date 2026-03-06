import Foundation

enum FeedbackImageLoader {
    static func prepareImageAttachment(
        from imageFileURL: URL?,
        loadData: @escaping @Sendable (URL) throws -> Data = { try Data(contentsOf: $0) }
    ) async -> Transport.Attachment? {
        guard let image = await prepareFeedbackImage(from: imageFileURL, loadData: loadData) else { return nil }
        return Transport.Attachment(data: image.data, fileName: image.fileName, mimeType: image.mimeType)
    }

    static func prepareFeedbackImage(
        from imageFileURL: URL?,
        loadData: @escaping @Sendable (URL) throws -> Data = { try Data(contentsOf: $0) }
    ) async -> FeedbackImage? {
        guard let imageFileURL else {
            ReporterLogger.log("FeedbackImageLoader", "No image provided, sending message without attachment")
            return nil
        }

        let fileExtension = imageFileURL.pathExtension.lowercased()
        guard let mimeType = FeedbackImage.mimeType(forFileExtension: fileExtension) else {
            ReporterLogger.log(
                "FeedbackImageLoader",
                "Unsupported image format '\(fileExtension)'. Supported: png, heic, jpeg, jpg. Sending without attachment"
            )
            return nil
        }

        do {
            let data = try await BackgroundTaskRunner.run {
                try loadData(imageFileURL)
            }
            ReporterLogger.log(
                "FeedbackImageLoader",
                "Loaded image attachment '\(imageFileURL.lastPathComponent)', size=\(data.count), mimeType=\(mimeType)"
            )
            return FeedbackImage(data: data, fileName: imageFileURL.lastPathComponent, mimeType: mimeType)
        } catch {
            ReporterLogger.log("FeedbackImageLoader", "Failed to read image at \(imageFileURL.path): \(error). Sending without attachment")
            return nil
        }
    }
}
