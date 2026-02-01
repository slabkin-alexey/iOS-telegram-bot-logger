//
//  MessageBuilder.swift
//

import Foundation
import UIKit

enum MessageBuilder {
    static func build(_ event: TelegramReporterEvent, additional: String) -> String {
        switch event {
        case .firstLaunch:
            return """
                ✅ First launch
                \(commonMeta(additional: additional))
                """
            
        case .appDidBecomeActive:
            return """
                ▶️ App active
                \(commonMeta(additional: additional))
                """
            
        case .custom(let title, let details):
            let detailsText = details
                .sorted(by: { $0.key < $1.key })
                .map { "• \($0.key): \($0.value)" }
                .joined(separator: "\n")
            
            return """
                🧩 \(title)
                \(commonMeta(additional: additional))
                \(detailsText.isEmpty ? "" : "\n" + detailsText)
                """
        }
    }
    
    private static func commonMeta(additional: String) -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let system = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let englishLocale = Locale(identifier: "en_US")

        var regionCode = ""
        if let identifier = Locale.current.region?.identifier {
            regionCode = identifier
        }
        
        var countryName = ""
        if let localizedCountryName = englishLocale.localizedString(forRegionCode: (regionCode)) {
            countryName = localizedCountryName
        }
        
#if DEBUG
let buildType = "Xcode"
#else
let buildType = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "TestFlight" : "AppStore"
#endif
        
        return """
        Name: \(appName) \(additional)
        Version: v\(version) (#\(build))
        Device: \(system) • \(idiom)
        Region: \(countryName)
        Source: \(buildType)
        """
    }
    
    private static var idiom: String = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        case .mac: return "Mac"
        case .tv: return "Apple TV"
        case .vision: return "Vision"
        default: return "Unknown"
        }
    }()
    
    private static var appName: String {
        let info = Bundle.main.infoDictionary

        if let displayName = info?["CFBundleDisplayName"] as? String, !displayName.isEmpty {
            return displayName
        }

        if let name = info?["CFBundleName"] as? String, !name.isEmpty {
            return name
        }

        return "Unknown App"
    }
    
    private static func readableCountryName(
        regionCode: String?,
        locale: Locale = .current
    ) -> String? {
        guard let regionCode else { return nil }
        
        return locale.localizedString(forRegionCode: regionCode)
    }
}
