//
//  Config.swift
//

import Foundation

struct Config {
    let token: String
    let chatID: String

    init(token: String, chatID: String) {
        self.token = token
        self.chatID = chatID
        ReporterLogger.log("Config", "Created config for chatID=\(chatID), tokenLength=\(token.count)")
    }
}
