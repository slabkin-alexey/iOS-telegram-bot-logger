//
//  TelegramReporter.swift
//

import Foundation
import UIKit

public enum TelegramReporter {
    public static func startLogReport(token: String, chatID: String, additional: String) async {
        do {
            let (_, isFirst) = try AccountInstallIdentity.getOrCreate()
            guard isFirst else { return }
            await TelegramReporter.report(.firstLaunch, token: token, chatID: chatID, additional: additional)
        } catch {
#if DEBUG
            print("AccountInstallIdentity error:", error)
#endif
        }
    }

    static func report(_ event: TelegramReporterEvent, token: String, chatID: String, additional: String) async {
        do {
            let cfg = try Config.load(token: token, chatID: chatID, additional: additional)
            let message = MessageBuilder.build(event, additional: additional)
            try await Transport.send(message, using: cfg)
        } catch {
#if DEBUG
            print("TelegramReporter error:", error)
#endif
        }
    }
}
