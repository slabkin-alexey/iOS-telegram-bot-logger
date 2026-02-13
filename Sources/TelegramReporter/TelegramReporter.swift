//
//  TelegramReporter.swift
//

import Foundation

public enum TelegramReporter {
    /// Sends first-launch report once per iCloud-synchronized account.
    public static func startLogReport(
        token: String,
        chatID: String,
        additional: String,
        ignoreFirstLaunch: Bool = false
    ) async {
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

    static func startLogReport(
        token: String,
        chatID: String,
        additional: String,
        ignoreFirstLaunch: Bool,
        getOrCreateInstallIdentity: () throws -> (id: String, isFirstForAccount: Bool),
        reportFirstLaunch: (String, String, String) async -> Void
    ) async {
        do {
            if ignoreFirstLaunch {
                await reportFirstLaunch(token, chatID, additional)
                return
            }

            let (_, isFirstForAccount) = try getOrCreateInstallIdentity()
            guard isFirstForAccount else { return }
            await reportFirstLaunch(token, chatID, additional)
        } catch {
            logDebugError("AccountInstallIdentity error", error)
        }
    }

    static func report(_ event: TelegramReporterEvent, token: String, chatID: String, additional: String) async {
        do {
            let cfg = Config(token: token, chatID: chatID)
            let message = MessageBuilder.build(event, additional: additional)
            try await Transport.send(message, using: cfg)
        } catch {
            logDebugError("TelegramReporter error", error)
        }
    }

    private static func logDebugError(_ prefix: String, _ error: Error) {
#if DEBUG
        print("\(prefix):", error)
#endif
    }
}
