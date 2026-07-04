import SwiftUI

struct ScheduledLockView: View {
    @State private var enabled = ScheduledLockManager.isEnabled
    @State private var start = ScheduledLockManager.startMinutes
    @State private var end = ScheduledLockManager.endMinutes

    var body: some View {
        ZStack {
            VANASIBackground()
            VStack(alignment: .leading, spacing: 28) {
                Toggle(isOn: $enabled) {
                    Text("Auto-enable daily")
                        .foregroundStyle(VANASITheme.textPrimary)
                }
                .tint(VANASITheme.textPrimary)

                VStack(alignment: .leading, spacing: 16) {
                    stepperRow("Start", minutes: $start)
                    stepperRow("End", minutes: $end)
                }

                Text("Shortcuts: When Focus turns on → Enable VANVASI Lock")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .lineSpacing(4)

                Spacer()
            }
            .padding(32)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
        .onDisappear(perform: save)
    }

    private func stepperRow(_ label: String, minutes: Binding<Int>) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(VANASITheme.textSecondary)
            Spacer()
            Button {
                minutes.wrappedValue = max(0, minutes.wrappedValue - 15)
            } label: {
                Image(systemName: "minus")
                    .foregroundStyle(VANASITheme.textSecondary)
            }
            Text(timeLabel(minutes.wrappedValue))
                .font(.body.monospacedDigit())
                .foregroundStyle(VANASITheme.textPrimary)
                .frame(width: 64)
            Button {
                minutes.wrappedValue = min(24 * 60, minutes.wrappedValue + 15)
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(VANASITheme.textSecondary)
            }
        }
    }

    private func save() {
        ScheduledLockManager.isEnabled = enabled
        ScheduledLockManager.startMinutes = start
        ScheduledLockManager.endMinutes = end
        ScheduledLockManager.applySchedule()
    }

    private func timeLabel(_ minutes: Int) -> String {
        String(format: "%d:%02d", minutes / 60, minutes % 60)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            Text(PrivacyPolicy.text)
                .font(.footnote.weight(.light))
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(6)
                .padding(32)
        }
        .background(VANASIBackground())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }
}

enum PrivacyPolicy {
    static let text = """
    VANVASI Privacy Policy

    Last updated: July 2026

    VANVASI works on your device only. No account. No cloud.

    We store: allowlist, lock state, session history, optional PIN (Keychain).

    We do not collect analytics or read content in other apps.

    Payments, if enabled, are processed by Apple.

    Contact: support@vanasi.app
    """
}
