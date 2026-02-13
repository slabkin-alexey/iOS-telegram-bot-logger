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
                ReporterLogger.log("TelegramReporter.startLogReport", "ignoreFirstLaunch=true, sending firstLaunch report immediately")
                await reportFirstLaunch(token, chatID, additional)
                return
            }

            let (_, isFirstForAccount) = try getOrCreateInstallIdentity()
            ReporterLogger.log("TelegramReporter.startLogReport", "Resolved install identity, isFirstForAccount=\(isFirstForAccount)")
            guard isFirstForAccount else {
                ReporterLogger.log("TelegramReporter.startLogReport", "Skipping report because this is not first launch for account")
                return
            }
            ReporterLogger.log("TelegramReporter.startLogReport", "Sending firstLaunch report for account")
            await reportFirstLaunch(token, chatID, additional)
        } catch {
            logDebugError("AccountInstallIdentity error", error)
        }
    }

    static func report(_ event: TelegramReporterEvent, token: String, chatID: String, additional: String) async {
        do {
            ReporterLogger.log("TelegramReporter.report", "Preparing event=\(event.logName), chatID=\(chatID)")
            let cfg = Config(token: token, chatID: chatID)
            let message = MessageBuilder.build(event, additional: additional)
            ReporterLogger.log("TelegramReporter.report", "Built message for event=\(event.logName), length=\(message.count)")
            try await Transport.send(message, using: cfg)
            ReporterLogger.log("TelegramReporter.report", "Sent event=\(event.logName) successfully")
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
