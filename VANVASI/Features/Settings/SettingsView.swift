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
                    VStack(spacing: 0) {
                        settingsLink("History") { SessionHistoryView() }
                        divider

                        settingsLink("PIN") { PINSetupView() }
                        settingsLink("Schedule") { ScheduledLockView() }
                        settingsLink("Free apps") { AllowlistEditorView() }
                        divider

                        toggleRow("Pay to unlock", isOn: $paymentsEnabled)
                            .onChange(of: paymentsEnabled) { _, v in
                                SharedStore.paymentsEnabled = v
                            }

                        divider

                        settingsLink("Privacy") { PrivacyPolicyView() }

                        Button {
                            if SharedStore.pinEnabled { showPINEndLock = true }
                            else { confirmEndLock = true }
                        } label: {
                            VANASIMinimalRow(title: "End lock", destructive: true)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("")
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

    private var divider: some View {
        Rectangle()
            .fill(VANASITheme.textWhisper.opacity(0.5))
            .frame(height: 0.5)
            .padding(.horizontal, 24)
    }

    private func settingsLink<D: View>(_ title: String, @ViewBuilder destination: () -> D) -> some View {
        NavigationLink(destination: destination()) {
            VANASIMinimalRow(title: title)
                .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
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
