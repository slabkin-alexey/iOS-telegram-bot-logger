//
//  Config.swift
//

import Foundation

struct Config {
    let token: String
    let chatID: String
    let additional: String

    static func load(token: String, chatID: String, additional: String) -> Config {
        Config(token: token, chatID: chatID, additional: additional)
    }
}
