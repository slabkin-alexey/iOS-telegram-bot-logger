//
//  MessageBuilder.swift
//

import Foundation

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

        case .feedback(let text, _):
            message = withAppTag("""
                📝 Feedback
                \(commonMeta(additional: additional))

                💬 User text: \(text)
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
        let countryName = localizedRegionName(for: regionCode)
        let languageCode = currentLanguageCode
        let localeName = localizedLanguageName(for: languageCode)
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
        currentLanguageCode(preferredLanguage: Locale.preferredLanguages.first)
    }

    static func currentLanguageCode(preferredLanguage: String?) -> String {
        preferredLanguage?
            .split(separator: "-")
            .first
            .map(String.init) ?? "Unknown"
    }

    private static var buildSource: String {
#if DEBUG
        "Xcode"
#else
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "TestFlight" : "AppStore"
#endif
    }

    private static var systemName: String {
#if os(iOS)
        "iOS"
#elseif os(tvOS)
        "tvOS"
#elseif os(visionOS)
        "visionOS"
#elseif os(macOS)
        "macOS"
#else
        "Unknown"
#endif
    }

    private static var systemVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    private static var idiom: String {
#if os(macOS)
        return "Mac"
#else
        return idiom(for: deviceModelName)
#endif
    }

    static func idiom(for deviceModelName: String) -> String {
        if deviceModelName.hasPrefix("iPhone") {
            return "iPhone"
        }
        if deviceModelName.hasPrefix("iPad") {
            return "iPad"
        }
        if deviceModelName.hasPrefix("Apple TV") {
            return "Apple TV"
        }
        if deviceModelName.hasPrefix("Apple Vision") || deviceModelName.hasPrefix("Vision") {
            return "Vision"
        }
        return "Unknown"
    }

    static func localizedRegionName(for regionCode: String, locale: Locale = englishLocale) -> String {
        locale.localizedString(forRegionCode: regionCode) ?? "Unknown"
    }

    static func localizedLanguageName(for languageCode: String, locale: Locale = englishLocale) -> String {
        locale.localizedString(forLanguageCode: languageCode) ?? "Unknown"
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
        DeviceModelResolver.currentModelName
    }

    private static func formatDetails(_ details: [String: String]) -> String {
        ReporterLogger.log("MessageBuilder.formatDetails", "Formatting details, count=\(details.count)")
        let sortedDetails = details.sorted { lhs, rhs in
            lhs.key < rhs.key
        }
        var lines: [String] = []
        lines.reserveCapacity(sortedDetails.count)

        for (key, value) in sortedDetails {
            let normalizedValue = value
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append("• \(key): \(normalizedValue)")
        }

        return lines.joined(separator: "\n")
    }

    private static func withAppTag(_ message: String) -> String {
        "\(message)\n\n#\(appHashtag)"
    }

    private static var appHashtag: String {
        let loweredName = appName.lowercased()
        var words: [String] = []
        words.reserveCapacity(loweredName.count)

        for component in loweredName.components(separatedBy: CharacterSet.alphanumerics.inverted) {
            if !component.isEmpty {
                words.append(component)
            }
        }

        let hashtag = words.joined()

        return hashtag.isEmpty ? "unknownapp" : hashtag
    }
}
