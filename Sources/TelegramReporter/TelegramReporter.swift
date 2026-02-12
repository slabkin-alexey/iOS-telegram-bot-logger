//
//  TelegramReporter.swift
//

import Foundation

public enum TelegramReporter {
    public static func startLogReport(
        token: String,
        chatID: String,
        additional: String,
        ignoreFirstLaunch: Bool = false
    ) async {
        do {
            if ignoreFirstLaunch {
                await report(.firstLaunch, token: token, chatID: chatID, additional: additional)
                return
            }

            let (_, isFirstForAccount) = try AccountInstallIdentity.getOrCreate()
            guard isFirstForAccount else { return }
            await report(.firstLaunch, token: token, chatID: chatID, additional: additional)
        } catch {
            logDebugError("AccountInstallIdentity error", error)
        }
    }

    static func report(_ event: TelegramReporterEvent, token: String, chatID: String, additional: String) async {
        do {
            let cfg = Config.load(token: token, chatID: chatID, additional: additional)
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
