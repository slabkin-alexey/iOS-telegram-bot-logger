import XCTest
@testable import TelegramReporterDemo

final class DemoLocalizationTests: XCTestCase {
    func testEnglishAndUkrainianLocalizationsShareSameKeySet() throws {
        let english = L10n.englishTable
        let ukrainian = L10n.ukrainianTable

        XCTAssertEqual(Set(english.keys), Set(ukrainian.keys))
        XCTAssertTrue(english.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        XCTAssertTrue(ukrainian.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }

    func testEnglishLocalizationUsesReleaseCopy() throws {
        let english = L10n.englishTable

        XCTAssertEqual(english["app.subtitle"], "A focused sample app for validating TelegramReporter locally, in Xcode, and in Xcode Cloud.")
        XCTAssertEqual(english["config.additional"], "App Tag")
        XCTAssertEqual(english["start.button"], "Send First-Launch Report")
        XCTAssertEqual(english["feedback.attach_sample"], "Attach Sample PNG")
        XCTAssertEqual(english["status.failure"], "Request failed: %@")
    }

    func testUkrainianLocalizationUsesNativeCopy() throws {
        let ukrainian = L10n.ukrainianTable

        XCTAssertEqual(ukrainian["config.chat_id"], "ID чату")
        XCTAssertEqual(ukrainian["custom.section"], "Довільна подія")
        XCTAssertEqual(ukrainian["feedback.section"], "Відгук")
        XCTAssertEqual(ukrainian["feedback.button"], "Надіслати відгук")
        XCTAssertEqual(ukrainian["status.failure"], "Не вдалося виконати запит: %@")
    }

    func testL10nReturnsEnglishStringsForEnglishLanguageCode() {
        XCTAssertEqual(L10n.tr("start.button", languageCode: "en"), "Send First-Launch Report")
        XCTAssertEqual(L10n.tr("feedback.image.attached", languageCode: "en-US"), "Sample PNG attached")
    }

    func testL10nReturnsUkrainianStringsForUkrainianLanguageCode() {
        XCTAssertEqual(L10n.tr("start.button", languageCode: "uk"), "Надіслати звіт про перший запуск")
        XCTAssertEqual(L10n.tr("feedback.image.attached", languageCode: "uk-UA"), "Тестове PNG додано")
    }

    func testL10nFallsBackToEnglishAndThenKey() {
        XCTAssertEqual(L10n.tr("status.ready", languageCode: "de"), "Ready to send")
        XCTAssertEqual(L10n.tr("missing.key", languageCode: "en"), "missing.key")
    }

    func testResolvedLanguageCodeSupportsNilAndUnderscoreSeparators() {
        XCTAssertEqual(L10n.resolvedLanguageCode(from: nil), "en")
        XCTAssertEqual(L10n.resolvedLanguageCode(from: "uk_UA"), "uk")
        XCTAssertEqual(L10n.resolvedLanguageCode(from: ""), "en")
    }

    func testTableFallsBackToEnglishForMissingLanguage() {
        XCTAssertEqual(L10n.table(for: nil)["status.ready"], "Ready to send")
    }

    func testLocaleUsesExpectedIdentifiers() {
        XCTAssertEqual(L10n.locale(for: nil).identifier, "en_US")
        XCTAssertEqual(L10n.locale(for: "uk-UA").identifier, "uk_UA")
    }

    func testFormatUsesExplicitLanguageCode() {
        XCTAssertEqual(
            L10n.format("status.failure", languageCode: "uk-UA", arguments: ["Помилка"]),
            "Не вдалося виконати запит: Помилка"
        )
        XCTAssertEqual(
            L10n.format("status.failure", languageCode: "en-US", arguments: ["Failure"]),
            "Request failed: Failure"
        )
    }
}
