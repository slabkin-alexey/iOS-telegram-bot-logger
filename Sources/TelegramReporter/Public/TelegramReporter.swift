import Foundation

public enum TelegramReporter {
    public typealias FeedbackError = TelegramReporterFeedbackError

    /// Sends first-launch report once per iCloud-synchronized account.
    public static func startLogReport(
        token: String,
        chatID: String,
        additional: String,
        ignoreFirstLaunch: Bool = false
    ) async {
        ReporterLogger.log(
            "TelegramReporter.startLogReport",
            "Started public API call, chatID=\(chatID), ignoreFirstLaunch=\(ignoreFirstLaunch), additionalLength=\(additional.count)"
        )
        await startLogReport(
            token: token,
            chatID: chatID,
            additional: additional,
            ignoreFirstLaunch: ignoreFirstLaunch,
            getOrCreateInstallIdentity: { try AccountInstallIdentity.getOrCreate() },
            reportFirstLaunch: { token, chatID, additional in
                await report(.firstLaunch, token: token, chatID: chatID, additional: additional)
            }
        )
    }

    /// Sends a custom event with optional image attachment.
    public static func sendCustomEvent(
        token: String,
        chatID: String,
        title: String,
        details: [String: String] = [:],
        additional: String,
        imageFileURL: URL? = nil
    ) async {
        let attachment = await FeedbackImageLoader.prepareImageAttachment(from: imageFileURL)
        await report(.custom(title: title, details: details), token: token, chatID: chatID, additional: additional, attachment: attachment)
    }

    /// Sends feedback event with the same base metadata as startLogReport plus user text.
    /// Optionally attaches an image with extension: png, heic, jpeg, jpg.
    public static func sendFeedback(
        token: String,
        chatID: String,
        additional: String,
        text: String,
        imageURL: URL? = nil,
        feedbackImage: FeedbackImage? = nil,
        imageFileURL: URL? = nil
    ) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            ReporterLogger.log("TelegramReporter.sendFeedback", "Rejected empty feedback message")
            throw FeedbackError.emptyMessage
        }

        ReporterLogger.log(
            "TelegramReporter.sendFeedback",
            "Preparing feedback event, chatID=\(chatID), textLength=\(trimmed.count), hasPickerImage=\(feedbackImage != nil), hasImageURL=\(imageURL != nil || imageFileURL != nil)"
        )
        let resolvedImageURL = imageURL ?? imageFileURL
        let image = if let feedbackImage {
            feedbackImage
        } else {
            await FeedbackImageLoader.prepareFeedbackImage(from: resolvedImageURL)
        }
        await report(.feedback(text: trimmed, image: image), token: token, chatID: chatID, additional: additional)
    }

    static func startLogReport(
        token: String,
        chatID: String,
        additional: String,
        ignoreFirstLaunch: Bool,
        getOrCreateInstallIdentity: @escaping @Sendable () throws -> (id: String, isFirstForAccount: Bool),
        reportFirstLaunch: (String, String, String) async -> Void
    ) async {
        do {
            let shouldSend = try await InstallIdentityService.shouldSendFirstLaunch(
                ignoreFirstLaunch: ignoreFirstLaunch,
                getOrCreateInstallIdentity: getOrCreateInstallIdentity
            )
            guard shouldSend else {
                ReporterLogger.log("TelegramReporter.startLogReport", "Skipping report because this is not first launch for account")
                return
            }
            ReporterLogger.log("TelegramReporter.startLogReport", "Sending firstLaunch report for account")
            await reportFirstLaunch(token, chatID, additional)
        } catch {
            logDebugError("AccountInstallIdentity error", error)
        }
    }

    static func report(
        _ event: TelegramReporterEvent,
        token: String,
        chatID: String,
        additional: String,
        attachment: Transport.Attachment? = nil
    ) async {
        do {
            try await ReporterService.report(
                event: event,
                token: token,
                chatID: chatID,
                additional: additional,
                attachment: attachment
            )
        } catch {
            logDebugError("TelegramReporter error", error)
        }
    }

    private static func logDebugError(_ prefix: String, _ error: Error) {
        ReporterLogger.log("TelegramReporter.error", "\(prefix): \(error)")
#if DEBUG
        print("\(prefix):", error)
#endif
    }
}
