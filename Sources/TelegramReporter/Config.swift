//
//  Config.swift
//

import Foundation

struct Config {
    let token: String
    let chatID: String
    let additional: String

    static func load(token: String, chatID: String, additional: String) throws -> Config {
        Config(token: token, chatID: token, additional: additional)
    }
    
    enum ConfigError: Error {
        case missingKeys
        case disabledInRelease
    }
}
