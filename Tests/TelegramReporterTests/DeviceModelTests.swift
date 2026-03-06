import XCTest
@testable import TelegramReporter

final class DeviceModelTests: XCTestCase {
    func testCurrentModelNameIsNotEmpty() {
        XCTAssertFalse(DeviceModelResolver.currentModelName.isEmpty)
    }

    func testCurrentModelNameMapsKnownIdentifiers() {
        XCTAssertEqual(DeviceModelResolver.currentModelName(resolvedIdentifier: "iPhone17,1"), "iPhone 16 Pro")
    }

    func testCurrentModelNameFallsBackToIdentifierForUnknownDevices() {
        XCTAssertEqual(DeviceModelResolver.currentModelName(resolvedIdentifier: "UnknownDevice,1"), "UnknownDevice,1")
    }

    func testResolvedHardwareIdentifierPrefersSimulatorIdentifier() {
        let identifier = DeviceModelResolver.resolvedHardwareIdentifier(
            simulatorIdentifier: "iPhone17,1",
            hardwareIdentifierProvider: { "ignored-device" }
        )

#if targetEnvironment(simulator)
        XCTAssertEqual(identifier, "iPhone17,1")
#else
        XCTAssertEqual(identifier, "ignored-device")
#endif
    }

    func testResolvedHardwareIdentifierFallsBackToHardwareIdentifier() {
        let identifier = DeviceModelResolver.resolvedHardwareIdentifier(
            simulatorIdentifier: nil,
            hardwareIdentifierProvider: { "iPhone14,6" }
        )

        XCTAssertEqual(identifier, "iPhone14,6")
    }

    func testHardwareIdentifierBuildsStringFromSystemInfo() {
        let identifier = DeviceModelResolver.hardwareIdentifier {
            Self.makeSystemInfo(machineIdentifier: "iPhone17,1")
        }

        XCTAssertEqual(identifier, "iPhone17,1")
    }

    func testHardwareIdentifierUsesDefaultSystemInfoProvider() {
        XCTAssertFalse(DeviceModelResolver.hardwareIdentifier().isEmpty)
    }

    func testResolvedHardwareIdentifierCanUseComputedHardwareIdentifier() {
        let identifier = DeviceModelResolver.resolvedHardwareIdentifier(
            simulatorIdentifier: nil,
            hardwareIdentifierProvider: { DeviceModelResolver.hardwareIdentifier() }
        )

        XCTAssertFalse(identifier.isEmpty)
    }

    func testCatalogContainsKnownMappings() {
        let known = DeviceModelCatalog.knownDeviceNames

        XCTAssertEqual(known["iPhone17,1"], "iPhone 16 Pro")
        XCTAssertEqual(known["iPad16,5"], "iPad Pro 13-inch (M4)")
        XCTAssertEqual(known["MacBookAir10,1"], "MacBook Air (M1, 2020)")
    }

    func testCatalogHasUniqueKeys() {
        let keys = Array(DeviceModelCatalog.knownDeviceNames.keys)
        XCTAssertEqual(Set(keys).count, keys.count)
    }

    private static func makeSystemInfo(machineIdentifier: String) -> utsname {
        var systemInfo = utsname()
        let capacity = MemoryLayout.size(ofValue: systemInfo.machine)
        let bytes = Array(machineIdentifier.utf8CString)

        withUnsafeMutablePointer(to: &systemInfo.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: capacity) { machinePointer in
                machinePointer.initialize(repeating: 0, count: capacity)
                for (offset, byte) in bytes.enumerated() where offset < capacity {
                    machinePointer[offset] = byte
                }
            }
        }

        return systemInfo
    }
}
