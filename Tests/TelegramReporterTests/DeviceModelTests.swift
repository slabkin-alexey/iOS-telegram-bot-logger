import XCTest
@testable import TelegramReporter

final class DeviceModelTests: XCTestCase {
    func testCurrentModelNameIsNotEmpty() {
        XCTAssertFalse(DeviceModelResolver.currentModelName.isEmpty)
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
}
