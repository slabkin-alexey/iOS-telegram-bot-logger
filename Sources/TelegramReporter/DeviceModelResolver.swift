//
//  DeviceModelResolver.swift
//

import Foundation

enum DeviceModelResolver {
    static var currentModelName: String {
        let identifier = resolvedHardwareIdentifier
        let modelName = knownDeviceNames[identifier] ?? identifier
        ReporterLogger.log(
            "DeviceModelResolver.currentModelName",
            "Resolved model identifier=\(identifier), mappedName=\(modelName)"
        )
        return modelName
    }

    private static var resolvedHardwareIdentifier: String {
#if targetEnvironment(simulator)
        if let simulatorIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"], !simulatorIdentifier.isEmpty {
            ReporterLogger.log("DeviceModelResolver.resolvedHardwareIdentifier", "Using simulator identifier=\(simulatorIdentifier)")
            return simulatorIdentifier
        }
#endif
        ReporterLogger.log("DeviceModelResolver.resolvedHardwareIdentifier", "Using hardware identifier=\(hardwareIdentifier)")
        return hardwareIdentifier
    }

    private static let hardwareIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)

        return withUnsafePointer(to: &systemInfo.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }()

    private static let knownDeviceNames = DeviceModelCatalog.knownDeviceNames
}
