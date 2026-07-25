import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var lockManager: MonkLockManager
    @State private var confirmEndLock = false
    @State private var showPINEndLock = false
    @State private var paymentsEnabled = SharedStore.paymentsEnabled

    var body: some View {
        NavigationStack {
            ZStack {
                VANASIBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        sectionHeader("Focus")
                        settingsLink("Merit", subtitle: "How points and levels work") {
                            MeritGuideView()
                        }
                        settingsLink("How it works", subtitle: "Setup, shields, and unlock flow") {
                            HowItWorksView()
                        }
                        settingsLink("History", subtitle: "Unlocks and lock events") {
                            SessionHistoryView()
                        }
                        divider

                        sectionHeader("Security")
                        settingsLink("PIN", subtitle: "Protect ending monk mode") {
                            PINSetupView()
                        }
                        settingsLink("Schedule", subtitle: "Auto-enable lock daily") {
                            ScheduledLockView()
                        }
                        settingsLink("Free apps", subtitle: "Phone, Messages, VANVASI") {
                            AllowlistEditorView()
                        }
                        divider

                        sectionHeader("About")
                        settingsLink("Privacy", subtitle: "On-device data only") {
                            PrivacyPolicyView()
                        }

                        if VANVASIConfig.showPaymentsInSettings {
                            divider
                            toggleRow("Pay to unlock", isOn: $paymentsEnabled)
                                .onChange(of: paymentsEnabled) { _, v in
                                    SharedStore.paymentsEnabled = v
                                }
                        }

                        divider

                        Button {
                            if SharedStore.pinEnabled { showPINEndLock = true }
                            else { confirmEndLock = true }
                        } label: {
                            VANASIMinimalRow(
                                title: "End lock",
                                subtitle: "Turn off monk mode now",
                                destructive: true
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(VANASITheme.textSecondary)
                }
            }
            .toolbarBackground(VANASITheme.void, for: .navigationBar)
            .confirmationDialog("End lock?", isPresented: $confirmEndLock) {
                Button("End lock", role: .destructive) { endLock() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showPINEndLock) {
                PINEntryView(
                    title: "PIN to end lock",
                    onSubmit: { pin in
                        if lockManager.disableLock(requirePIN: true, pin: pin, context: context) {
                            context.insert(LockEvent(action: LockEventAction.emergencyExit))
                            try? context.save()
                            showPINEndLock = false
                            dismiss()
                        }
                    },
                    onCancel: { showPINEndLock = false }
                )
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption2)
            .tracking(2)
            .foregroundStyle(VANASITheme.textWhisper)
            .padding(.horizontal, 24)
            .padding(.top, 12)
    }

    private var divider: some View {
        Rectangle()
            .fill(VANASITheme.textWhisper.opacity(0.5))
            .frame(height: 0.5)
            .padding(.horizontal, 24)
    }

    private func settingsLink<D: View>(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder destination: () -> D
    ) -> some View {
        NavigationLink(destination: destination()) {
            VANASIMinimalRow(title: title, subtitle: subtitle, showChevron: true)
                .padding(.horizontal, 24)
        }
        .buttonStyle(VANASISettingsRowButtonStyle())
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.body)
                .foregroundStyle(VANASITheme.textPrimary)
        }
        .tint(VANASITheme.textPrimary)
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    private func endLock() {
        lockManager.disableLock(requirePIN: false, context: context)
        context.insert(LockEvent(action: LockEventAction.emergencyExit))
        try? context.save()
        dismiss()
    }
}

struct VANASISettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.white.opacity(configuration.isPressed ? 0.05 : 0)
            )
            .animation(VANASITheme.springSnappy, value: configuration.isPressed)
    }
}
