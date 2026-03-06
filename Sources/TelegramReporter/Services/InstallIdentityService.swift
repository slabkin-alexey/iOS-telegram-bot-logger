import Foundation

enum InstallIdentityService {
    static func shouldSendFirstLaunch(
        ignoreFirstLaunch: Bool,
        getOrCreateInstallIdentity: @escaping @Sendable () throws -> (id: String, isFirstForAccount: Bool)
    ) async throws -> Bool {
        if ignoreFirstLaunch {
            ReporterLogger.log("InstallIdentityService", "ignoreFirstLaunch=true, force sending first-launch report")
            return true
        }

        let (_, isFirstForAccount) = try await BackgroundTaskRunner.run {
            try getOrCreateInstallIdentity()
        }
        ReporterLogger.log("InstallIdentityService", "Resolved account identity, isFirstForAccount=\(isFirstForAccount)")
        return isFirstForAccount
    }
}
