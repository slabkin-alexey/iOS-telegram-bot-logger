import Foundation

enum InstallIdentityService {
    static func shouldSendFirstLaunch(ignoreFirstLaunch: Bool) throws -> Bool {
        if ignoreFirstLaunch {
            ReporterLogger.log("InstallIdentityService", "ignoreFirstLaunch=true, force sending first-launch report")
            return true
        }

        let (_, isFirstForAccount) = try AccountInstallIdentity.getOrCreate()
        ReporterLogger.log("InstallIdentityService", "Resolved account identity, isFirstForAccount=\(isFirstForAccount)")
        return isFirstForAccount
    }
}
