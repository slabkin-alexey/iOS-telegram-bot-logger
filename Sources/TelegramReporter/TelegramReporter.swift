//
//  TelegramReporter.swift
//

import Foundation
import UIKit

public enum TelegramReporter {
    public static func startLogReport(token: String, chatID: String) async {
        do {
            let (_, isFirst) = try AccountInstallIdentity.getOrCreate()
            guard isFirst else { return }
            await TelegramReporter.report(.firstLaunch, token: token, chatID: chatID)
        } catch {
#if DEBUG
            print("AccountInstallIdentity error:", error)
#endif
        }
    }

    static func report(_ event: TelegramReporterEvent, token: String, chatID: String) async {
        do {
            let cfg = try Config.load(token: token, chatID: chatID)
            let message = MessageBuilder.build(event)
            try await Transport.send(message, using: cfg)
        } catch {
#if DEBUG
            print("TelegramReporter error:", error)
#endif
        }
    }
}
