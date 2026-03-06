import Foundation

enum L10n {
    static let englishTable: [String: String] = [
        "app.title": "TelegramReporter Demo",
        "app.subtitle": "A focused sample app for validating TelegramReporter locally, in Xcode, and in Xcode Cloud.",
        "config.section": "Configuration",
        "config.token": "Bot Token",
        "config.chat_id": "Chat ID",
        "config.additional": "App Tag",
        "start.section": "First Launch",
        "start.button": "Send First-Launch Report",
        "custom.section": "Custom Event",
        "custom.title": "Event Title",
        "custom.default_title": "Demo Event",
        "custom.button": "Send Custom Event",
        "feedback.section": "Feedback",
        "feedback.message": "Feedback Message",
        "feedback.placeholder": "Describe what happened...",
        "feedback.attach_sample": "Attach Sample PNG",
        "feedback.clear_image": "Remove Image",
        "feedback.button": "Send Feedback",
        "feedback.image.none": "No image attached",
        "feedback.image.attached": "Sample PNG attached",
        "status.section": "Status",
        "status.ready": "Ready to send",
        "status.start.success": "First-launch report sent successfully.",
        "status.custom.success": "Custom event sent successfully.",
        "status.feedback.success": "Feedback sent successfully.",
        "status.feedback.success_with_image": "Feedback with image sent successfully.",
        "status.failure": "Request failed: %@"
    ]

    static let ukrainianTable: [String: String] = [
        "app.title": "Демо TelegramReporter",
        "app.subtitle": "Компактний демо-застосунок для перевірки TelegramReporter локально, у Xcode та в Xcode Cloud.",
        "config.section": "Налаштування",
        "config.token": "Токен бота",
        "config.chat_id": "ID чату",
        "config.additional": "Тег застосунку",
        "start.section": "Перший запуск",
        "start.button": "Надіслати звіт про перший запуск",
        "custom.section": "Довільна подія",
        "custom.title": "Назва події",
        "custom.default_title": "Демо-подія",
        "custom.button": "Надіслати подію",
        "feedback.section": "Відгук",
        "feedback.message": "Текст повідомлення",
        "feedback.placeholder": "Опишіть, що сталося...",
        "feedback.attach_sample": "Додати тестове PNG",
        "feedback.clear_image": "Прибрати зображення",
        "feedback.button": "Надіслати відгук",
        "feedback.image.none": "Зображення не додано",
        "feedback.image.attached": "Тестове PNG додано",
        "status.section": "Статус",
        "status.ready": "Готово до відправлення",
        "status.start.success": "Звіт про перший запуск успішно надіслано.",
        "status.custom.success": "Подію успішно надіслано.",
        "status.feedback.success": "Відгук успішно надіслано.",
        "status.feedback.success_with_image": "Відгук із зображенням успішно надіслано.",
        "status.failure": "Не вдалося виконати запит: %@"
    ]

    static func tr(_ key: String, languageCode: String? = nil) -> String {
        let table = table(for: languageCode ?? Locale.preferredLanguages.first)
        return table[key] ?? englishTable[key] ?? key
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        format(key, languageCode: Locale.preferredLanguages.first, arguments: arguments)
    }

    static func format(_ key: String, languageCode: String?, arguments: [CVarArg]) -> String {
        String(
            format: tr(key, languageCode: languageCode),
            locale: locale(for: languageCode),
            arguments: arguments
        )
    }

    static func table(for preferredLanguage: String?) -> [String: String] {
        resolvedLanguageCode(from: preferredLanguage) == "uk" ? ukrainianTable : englishTable
    }

    static func locale(for preferredLanguage: String?) -> Locale {
        resolvedLanguageCode(from: preferredLanguage) == "uk"
            ? Locale(identifier: "uk_UA")
            : Locale(identifier: "en_US")
    }

    static func resolvedLanguageCode(from preferredLanguage: String?) -> String {
        guard let preferredLanguage else {
            return "en"
        }
        return preferredLanguage
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .first
            .map(String.init) ?? "en"
    }
}
