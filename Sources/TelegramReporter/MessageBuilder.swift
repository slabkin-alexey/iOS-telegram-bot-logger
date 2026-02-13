//
//  MessageBuilder.swift
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum MessageBuilder {
    static func build(_ event: TelegramReporterEvent, additional: String) -> String {
        ReporterLogger.log(
            "MessageBuilder.build",
            "Building message for event=\(event.logName), additionalLength=\(additional.count)"
        )

        let message: String
        switch event {
        case .firstLaunch:
            message = withAppTag("""
                ✅ First Launch
                \(commonMeta(additional: additional))
                """)

        case .appDidBecomeActive:
            message = withAppTag("""
                ▶️ App Became Active
                \(commonMeta(additional: additional))
                """)

        case .custom(let title, let details):
            let detailsText = formatDetails(details)

            message = withAppTag("""
                🧩 \(title)
                \(commonMeta(additional: additional))
                \(detailsText.isEmpty ? "" : "\n📋 Details:\n" + detailsText)
                """)
        }

        ReporterLogger.log("MessageBuilder.build", "Message built, finalLength=\(message.count)")
        return message
    }

    private static func commonMeta(additional: String) -> String {
        let version = appVersion
        let build = appBuild
        let system = "\(systemName) \(systemVersion)"
        let regionCode = currentRegionCode
        let countryName = englishLocale.localizedString(forRegionCode: regionCode) ?? "Unknown"
        let languageCode = currentLanguageCode
        let localeName = englishLocale.localizedString(forLanguageCode: languageCode) ?? "Unknown"
        let displayNameSuffix = additional.trimmingCharacters(in: .whitespacesAndNewlines)

        return [
            "📱 App: \(appName)\(displayNameSuffix.isEmpty ? "" : " • \(displayNameSuffix)")",
            "📦 Version: \(version) (\(build))",
            "🚚 Source: \(buildSource)",
            "📲 Device: \(idiom) • \(deviceModelName)",
            "🧠 OS: \(system)",
            "🌍 Locale: \(localeName)",
            "🗺️ Region: \(countryName) (\(regionCode))"
        ].joined(separator: "\n")
    }

    private static let englishLocale = Locale(identifier: "en_US")

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    private static var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }

    private static var currentRegionCode: String {
        currentRegionCode(regionIdentifier: Locale.current.region?.identifier)
    }

    static func currentRegionCode(
        regionIdentifier: String?
    ) -> String {
        regionIdentifier ?? "Unknown"
    }

    private static var currentLanguageCode: String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "Unknown"
        return preferredLanguage.split(separator: "-").first.map(String.init) ?? "Unknown"
    }

    private static var buildSource: String {
#if DEBUG
        "Xcode"
#else
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "TestFlight" : "AppStore"
#endif
    }

    private static var systemName: String {
#if canImport(UIKit)
        UIDevice.current.systemName
#else
        "Unknown"
#endif
    }

    private static var systemVersion: String {
#if canImport(UIKit)
        UIDevice.current.systemVersion
#else
        ProcessInfo.processInfo.operatingSystemVersionString
#endif
    }

    private static var idiom: String {
#if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        case .mac: return "Mac"
        case .tv: return "Apple TV"
        case .vision: return "Vision"
        default: return "Unknown"
        }
#else
        return "Unknown"
#endif
    }

    private static var appName: String {
        appName(from: Bundle.main.infoDictionary)
    }

    static func appName(from info: [String: Any]?) -> String {
        if let displayName = info?["CFBundleDisplayName"] as? String, !displayName.isEmpty {
            return displayName
        }

        if let name = info?["CFBundleName"] as? String, !name.isEmpty {
            return name
        }

        return "Unknown App"
    }

    private static var deviceModelName: String {
#if canImport(UIKit)
        DeviceModelResolver.currentModelName
#else
        "Unknown Device"
#endif
    }

    private static func formatDetails(_ details: [String: String]) -> String {
        ReporterLogger.log("MessageBuilder.formatDetails", "Formatting details, count=\(details.count)")
        return details
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
