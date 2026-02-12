//
//  DeviceModelResolver.swift
//

import Foundation

enum DeviceModelResolver {
    static var currentModelName: String {
        let identifier = resolvedHardwareIdentifier
        return knownDeviceNames[identifier] ?? identifier
    }

    private static var resolvedHardwareIdentifier: String {
#if targetEnvironment(simulator)
        if let simulatorIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"], !simulatorIdentifier.isEmpty {
            return simulatorIdentifier
        }
#endif
        return hardwareIdentifier
    }

    private static var hardwareIdentifier: String = {
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
