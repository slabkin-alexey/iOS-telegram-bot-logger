//
//  Config.swift
//

import Foundation

struct Config {
    let token: String
    let chatID: String
    
    static func load(token: String, chatID: String) throws -> Config {
        Config(token: token, chatID: token)
    }
    
    enum ConfigError: Error {
        case missingKeys
        case disabledInRelease
    }
}
