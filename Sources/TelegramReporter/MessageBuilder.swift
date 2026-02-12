//
//  MessageBuilder.swift
//

import Foundation
import UIKit

enum MessageBuilder {
    static func build(_ event: TelegramReporterEvent, additional: String) -> String {
        switch event {
        case .firstLaunch:
            return withAppTag("""
                ✅ First Launch
                \(commonMeta(additional: additional))
                """)
            
        case .appDidBecomeActive:
            return withAppTag("""
                ▶️ App Became Active
                \(commonMeta(additional: additional))
                """)
            
        case .custom(let title, let details):
            let detailsText = formatDetails(details)
            
            return withAppTag("""
                🧩 \(title)
                \(commonMeta(additional: additional))
                \(detailsText.isEmpty ? "" : "\n📋 Details:\n" + detailsText)
                """)
        }
    }
    
    private static func commonMeta(additional: String) -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let system = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let regionCode = Locale.current.region?.identifier ?? "Unknown"
        let countryName = Locale(identifier: "en_US").localizedString(forRegionCode: regionCode) ?? "Unknown"
        let preferredLanguage = Locale.preferredLanguages.first ?? "Unknown"
        let languageCode = preferredLanguage.split(separator: "-").first.map(String.init) ?? "Unknown"
        let localeName = Locale(identifier: "en_US").localizedString(forLanguageCode: languageCode) ?? "Unknown"
        let displayNameSuffix = additional.trimmingCharacters(in: .whitespacesAndNewlines)
#if DEBUG
        let buildType = "Xcode"
#else
        let buildType = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "TestFlight" : "AppStore"
#endif

        return [
            "📱 App: \(appName)\(displayNameSuffix.isEmpty ? "" : " • \(displayNameSuffix)")",
            "📦 Version: \(version) (\(build))",
            "🚚 Source: \(buildType)",
            "📲 Device: \(idiom) • \(deviceModelName)",
            "🧠 OS: \(system)",
            "🌍 Locale: \(localeName)",
            "🗺️ Region: \(countryName) (\(regionCode))"
        ].joined(separator: "\n")
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
    
    private static var deviceModelIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }()

    private static var deviceModelName: String {
        let identifier = deviceModelIdentifier
        return knownDeviceNames[identifier] ?? identifier
    }

    private static let knownDeviceNames: [String: String] = [
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",

        "iPad14,8": "iPad Air 11-inch (M2)",
        "iPad14,9": "iPad Air 11-inch (M2)",
        "iPad14,10": "iPad Air 13-inch (M2)",
        "iPad14,11": "iPad Air 13-inch (M2)",
        "iPad16,3": "iPad Pro 11-inch (M4)",
        "iPad16,4": "iPad Pro 11-inch (M4)",
        "iPad16,5": "iPad Pro 13-inch (M4)",
        "iPad16,6": "iPad Pro 13-inch (M4)",
        "iPad13,18": "iPad (10th generation)",
        "iPad13,19": "iPad (10th generation)",
        "iPad14,1": "iPad mini (6th generation)",
        "iPad14,2": "iPad mini (6th generation)",

        "Mac14,2": "MacBook Air (M2)",
        "Mac14,3": "Mac mini (M2)",
        "Mac14,5": "MacBook Pro 14-inch (M2 Pro/Max)",
        "Mac14,6": "MacBook Pro 16-inch (M2 Pro/Max)",
        "Mac15,3": "MacBook Air (M3)",
        "Mac15,6": "MacBook Pro 14-inch (M3 Pro/Max)",
        "Mac15,8": "MacBook Pro 16-inch (M3 Pro/Max)"
    ]
    
    private static func formatDetails(_ details: [String: String]) -> String {
        details
            .sorted(by: { $0.key < $1.key })
            .map { key, value in
                let normalizedValue = value
                    .replacingOccurrences(of: "\n", with: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return "• \(key): \(normalizedValue)"
            }
            .joined(separator: "\n")
    }

    private static func withAppTag(_ message: String) -> String {
        "\(message)\n\n#\(appHashtag)"
    }

    private static var appHashtag: String {
        let words = appName
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined()

        return words.isEmpty ? "unknownapp" : words
    }
}
