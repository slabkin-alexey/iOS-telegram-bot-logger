import SwiftUI

struct ContentView: View {
    @State private var viewModel: DemoScreenViewModel

    init(viewModel: DemoScreenViewModel = DemoScreenViewModel(client: DemoReporterClientFactory.make())) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    configurationCard
                    startCard
                    customCard
                    feedbackCard
                    statusCard
                }
                .padding(20)
            }
            .background(background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.tr("app.title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(L10n.tr("app.subtitle"))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.84))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.10, green: 0.21, blue: 0.42), Color(red: 0.12, green: 0.46, blue: 0.62)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var configurationCard: some View {
        card(title: L10n.tr("config.section")) {
            VStack(spacing: 12) {
                textField(L10n.tr("config.token"), text: $viewModel.token, identifier: DemoAccessibilityID.tokenField)
                textField(L10n.tr("config.chat_id"), text: $viewModel.chatID, identifier: DemoAccessibilityID.chatIDField)
                textField(L10n.tr("config.additional"), text: $viewModel.additional, identifier: DemoAccessibilityID.additionalField)
            }
        }
    }

    private var startCard: some View {
        card(title: L10n.tr("start.section")) {
            actionButton(
                title: L10n.tr("start.button"),
                identifier: DemoAccessibilityID.sendStartButton
            ) {
                await viewModel.sendStartReport()
            }
        }
    }

    private var customCard: some View {
        card(title: L10n.tr("custom.section")) {
            VStack(spacing: 12) {
                textField(L10n.tr("custom.title"), text: $viewModel.customTitle, identifier: DemoAccessibilityID.customTitleField)
                actionButton(
                    title: L10n.tr("custom.button"),
                    identifier: DemoAccessibilityID.sendCustomButton
                ) {
                    await viewModel.sendCustomEvent()
                }
            }
        }
    }

    private var feedbackCard: some View {
        card(title: L10n.tr("feedback.section")) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.tr("feedback.message"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.14, green: 0.20, blue: 0.30))

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.feedbackText)
                        .frame(minHeight: 140)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(red: 0.79, green: 0.84, blue: 0.90), lineWidth: 1)
                        )
                        .accessibilityIdentifier(DemoAccessibilityID.feedbackTextEditor)

                    if viewModel.feedbackText.isEmpty {
                        Text(L10n.tr("feedback.placeholder"))
                            .foregroundStyle(Color(red: 0.48, green: 0.54, blue: 0.62))
                            .padding(.horizontal, 14)
                            .padding(.top, 18)
                            .allowsHitTesting(false)
                    }
                }

                HStack(spacing: 10) {
                    secondaryButton(
                        title: L10n.tr("feedback.attach_sample"),
                        identifier: DemoAccessibilityID.attachImageButton
                    ) {
                        viewModel.attachSampleImage()
                    }

                    secondaryButton(
                        title: L10n.tr("feedback.clear_image"),
                        identifier: DemoAccessibilityID.clearImageButton
                    ) {
                        viewModel.clearFeedbackImage()
                    }
                }

                Text(viewModel.feedbackImageDescription)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.25, green: 0.32, blue: 0.40))
                    .accessibilityIdentifier(DemoAccessibilityID.imageStateLabel)

                actionButton(
                    title: L10n.tr("feedback.button"),
                    identifier: DemoAccessibilityID.sendFeedbackButton
                ) {
                    await viewModel.sendFeedback()
                }
            }
        }
    }

    private var statusCard: some View {
        card(title: L10n.tr("status.section")) {
            Text(viewModel.statusMessage)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(viewModel.isError ? Color.red : Color(red: 0.10, green: 0.42, blue: 0.24))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(DemoAccessibilityID.statusLabel)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99),
                Color(red: 0.92, green: 0.95, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.10, green: 0.16, blue: 0.24))

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
    }

    private func textField(_ title: String, text: Binding<String>, identifier: String) -> some View {
        TextField(title, text: text)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(red: 0.79, green: 0.84, blue: 0.90), lineWidth: 1)
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .accessibilityIdentifier(identifier)
    }

    private func actionButton(title: String, identifier: String, action: @escaping @Sendable () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            HStack {
                if viewModel.isSending {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.33, blue: 0.64))
            )
        }
        .disabled(viewModel.isSending)
        .accessibilityIdentifier(identifier)
    }

    private func secondaryButton(title: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(Color(red: 0.10, green: 0.33, blue: 0.64))
        .accessibilityIdentifier(identifier)
    }
}
