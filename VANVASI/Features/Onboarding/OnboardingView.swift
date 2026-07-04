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

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Group {
                    switch step {
                    case 0: introStep
                    case 1: permissionStep
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
            if phase == .active, step == 1,
               AuthorizationCenter.shared.authorizationStatus == .approved {
                step = 2
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
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

            Text("Calls and messages stay open.\nEverything else waits.")
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

    private var permissionStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Screen Time")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Apple will ask for your passcode once. Required to shield apps.")
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
                Button("Continue") { step = 2 }
                    .buttonStyle(VANASITextButton())
            }
        }
    }

    private var allowlistStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Free apps")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Phone, Messages, and VANVASI.")
                .font(.footnote)
                .foregroundStyle(VANASITheme.textSecondary)

            FamilyActivityPicker(selection: $lockManager.allowedSelection)
                .frame(height: 240)

            if let lockError {
                Text(lockError).font(.footnote).foregroundStyle(.orange)
            }

            Button("Enable lock") {
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
            Button("Demo") {
                if lockManager.enableLock() { onComplete() }
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
