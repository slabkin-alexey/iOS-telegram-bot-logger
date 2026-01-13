//
//  InstallEvent.swift
//

import Foundation

enum InstallEvent {
    case firstEver(installID: String)
    case reinstall(installID: String)
    case normal(installID: String)
}
