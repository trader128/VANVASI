import SwiftUI
import FamilyControls

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var step = 0
    @State private var authError: String?
    @State private var lockError: String?
    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 32)

                Group {
                    switch step {
                    case 0: introStep
                    case 1: permissionStep
                    default: allowlistStep
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, step == 1,
               AuthorizationCenter.shared.authorizationStatus == .approved {
                step = 2
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("VANVASI")
                .font(.caption.weight(.semibold))
                .tracking(4)
                .foregroundStyle(VANASITheme.accent)
            Text("Monk mode\nfor your mind")
                .font(.system(size: 36, weight: .light, design: .serif))
                .foregroundStyle(VANASITheme.textPrimary)
                .lineSpacing(4)
        }
    }

    private var introStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Lock everything except calls and messages. Unlock with intention — not impulse.")
                .font(.body)
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(4)

            featureRow(icon: "phone.fill", text: "Phone & Messages always free")
            featureRow(icon: "lock.shield", text: "Everything else paused")
            featureRow(icon: "wind", text: "Breathing pause before you unlock")

            Button("Begin setup") {
                VANASIHaptics.light()
                step = 1
            }
            .buttonStyle(VANASIPrimaryButton())
        }
    }

    private var permissionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Screen Time access")
                .font(.title3.weight(.semibold))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Apple will ask for your passcode once. This protects your focus settings — the same way Opal and One Sec work.")
                .font(.subheadline)
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(3)

            if let authError {
                Text(authError).font(.footnote).foregroundStyle(.orange)
            }

            Button("Grant access") {
                Task { await requestAuthorization() }
            }
            .buttonStyle(VANASIPrimaryButton())

            if AuthorizationCenter.shared.authorizationStatus == .approved {
                Button("Continue") { step = 2 }
                    .buttonStyle(VANASISecondaryButton())
            }
        }
    }

    private var allowlistStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Apps that stay free")
                .font(.title3.weight(.semibold))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Select Phone, Messages, and VANVASI. Without VANVASI selected, you lock yourself out.")
                .font(.footnote)
                .foregroundStyle(VANASITheme.textSecondary)

            HStack {
                Circle()
                    .fill(lockManager.allowedSelection.allowedAppCount >= 3 ? VANASITheme.success : VANASITheme.accent)
                    .frame(width: 8, height: 8)
                Text("\(lockManager.allowedSelection.allowedAppCount) selected · need 3+")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textSecondary)
            }

            FamilyActivityPicker(selection: $lockManager.allowedSelection)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if let lockError {
                Text(lockError).font(.footnote).foregroundStyle(.orange)
            }

            Button("Enable VANVASI Lock") {
                VANASIHaptics.medium()
                lockManager.persistSelection()
                if lockManager.enableLock() {
                    onComplete()
                } else {
                    lockError = lockManager.lastError
                }
            }
            .buttonStyle(VANASIPrimaryButton())
            .disabled(enableButtonDisabled)

            #if targetEnvironment(simulator)
            Button("Demo (Simulator)") {
                if lockManager.enableLock() { onComplete() }
            }
            .font(.caption)
            .foregroundStyle(VANASITheme.textSecondary)
            #endif
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(VANASITheme.accent)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(VANASITheme.textPrimary)
        }
    }

    private var enableButtonDisabled: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return !lockManager.allowedSelection.isValidAllowlist
        #endif
    }

    private func requestAuthorization() async {
        authError = nil
        if AuthorizationCenter.shared.authorizationStatus == .approved {
            step = 2
            return
        }
        #if targetEnvironment(simulator)
        step = 2
        #else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            step = 2
        } catch {
            authError = error.localizedDescription
        }
        #endif
    }
}
