import SwiftUI
import FamilyControls
import SwiftData

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var step = 0
    @State private var authError: String?
    @State private var lockError: String?
    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    private let stepCount = 4

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Group {
                    switch step {
                    case 0: introStep
                    case 1: howItWorksStep
                    case 2: permissionStep
                    default: allowlistStep
                    }
                }

                Spacer()

                stepIndicator
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, step == 2,
               AuthorizationCenter.shared.authorizationStatus == .approved {
                step = 3
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<stepCount, id: \.self) { i in
                Circle()
                    .fill(i == step ? VANASITheme.textPrimary : VANASITheme.textWhisper)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var introStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Monk mode\nfor your mind")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(VANASITheme.textPrimary)
                .lineSpacing(6)

            Text("VANVASI locks your iPhone to calls and messages. Everything else waits until you unlock with intention.")
                .font(.body.weight(.light))
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(6)

            Button("Continue") {
                VANASIHaptics.light()
                step = 1
            }
            .buttonStyle(VANASIPrimaryButton())
        }
    }

    private var howItWorksStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("How it works")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(VANASITheme.textPrimary)

            VStack(alignment: .leading, spacing: 14) {
                bullet("Turn on the lock ring on the home screen.")
                bullet("Open a blocked app → shield appears.")
                bullet("Unlock in VANVASI after a short pause.")
                bullet("Access ends automatically; monk mode returns.")
            }

            Text("You can end lock anytime from Settings.")
                .font(.footnote)
                .foregroundStyle(VANASITheme.textWhisper)

            Button("Continue") {
                VANASIHaptics.light()
                step = 2
            }
            .buttonStyle(VANASIPrimaryButton())
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("·")
                .foregroundStyle(VANASITheme.textSecondary)
            Text(text)
                .font(.subheadline.weight(.light))
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(3)
        }
    }

    private var permissionStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Screen Time")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Apple asks for your device passcode once. VANVASI uses Screen Time to shield apps — the same API trusted by leading focus apps.")
                .font(.subheadline.weight(.light))
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(4)

            if let authError {
                Text(authError).font(.footnote).foregroundStyle(.orange)
            }

            Button("Grant access") {
                Task { await requestAuthorization() }
            }
            .buttonStyle(VANASIPrimaryButton())

            if AuthorizationCenter.shared.authorizationStatus == .approved {
                Button("Continue") { step = 3 }
                    .buttonStyle(VANASITextButton())
            }
        }
    }

    private var allowlistStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Free apps")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Select Phone, Messages, and VANVASI so you can always call, text, and turn lock off.")
                .font(.footnote)
                .foregroundStyle(VANASITheme.textSecondary)
                .lineSpacing(3)

            FamilyActivityPicker(selection: $lockManager.allowedSelection)
                .frame(height: 240)

            if let lockError {
                Text(lockError).font(.footnote).foregroundStyle(.orange)
            }

            Button("Enable monk mode") {
                VANASIHaptics.medium()
                lockManager.persistSelection()
                if lockManager.enableLock() {
                    context.insert(LockEvent(action: LockEventAction.enabled))
                    try? context.save()
                    ScheduledLockManager.applySchedule()
                    onComplete()
                } else {
                    lockError = lockManager.lastError
                }
            }
            .buttonStyle(VANASIPrimaryButton())
            .disabled(enableButtonDisabled)

            #if targetEnvironment(simulator)
            Button("Continue without lock") {
                onComplete()
            }
            .buttonStyle(VANASITextButton())
            #endif
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
            step = 3
            return
        }
        #if targetEnvironment(simulator)
        step = 3
        #else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            step = 3
        } catch {
            authError = error.localizedDescription
        }
        #endif
    }
}
