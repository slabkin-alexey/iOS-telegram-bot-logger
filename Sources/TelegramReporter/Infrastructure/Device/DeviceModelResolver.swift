//
//  DeviceModelResolver.swift
//

import Foundation

enum DeviceModelResolver {
    static var currentModelName: String {
        currentModelName(
            resolvedIdentifier: resolvedHardwareIdentifier(
                simulatorIdentifier: ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
                hardwareIdentifierProvider: currentHardwareIdentifier
            )
        )
    }

    static func currentModelName(resolvedIdentifier: String) -> String {
        let modelName = knownDeviceNames[resolvedIdentifier] ?? resolvedIdentifier
        ReporterLogger.log(
            "DeviceModelResolver.currentModelName",
            "Resolved model identifier=\(resolvedIdentifier), mappedName=\(modelName)"
        )
        return modelName
    }

    static func resolvedHardwareIdentifier(
        simulatorIdentifier: String?,
        hardwareIdentifierProvider: () -> String
    ) -> String {
#if targetEnvironment(simulator)
        if let simulatorIdentifier, !simulatorIdentifier.isEmpty {
            ReporterLogger.log("DeviceModelResolver.resolvedHardwareIdentifier", "Using simulator identifier=\(simulatorIdentifier)")
            return simulatorIdentifier
        }
#endif
        let resolvedHardwareIdentifier = hardwareIdentifierProvider()
        ReporterLogger.log("DeviceModelResolver.resolvedHardwareIdentifier", "Using hardware identifier=\(resolvedHardwareIdentifier)")
        return resolvedHardwareIdentifier
    }

    static func hardwareIdentifier(systemInfoProvider: () -> utsname = defaultSystemInfo) -> String {
        var systemInfo = systemInfoProvider()
        return withUnsafePointer(to: &systemInfo.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }

    static func currentHardwareIdentifier() -> String {
        hardwareIdentifier()
    }

    private static func defaultSystemInfo() -> utsname {
        var systemInfo = utsname()
        uname(&systemInfo)
        return systemInfo
    }

    private static let knownDeviceNames = DeviceModelCatalog.knownDeviceNames
}
