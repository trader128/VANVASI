import SwiftUI
import FamilyControls
import Combine
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.modelContext) private var context
    @Query(sort: \UnlockSession.startedAt, order: .reverse) private var sessions: [UnlockSession]
    @Query(sort: \LockEvent.date, order: .reverse) private var events: [LockEvent]

    @State private var showUnlockConfirm = false
    @State private var showSettings = false
    @State private var showAllowlistEditor = false
    @State private var showLockError = false
    @State private var showPINDisable = false
    @State private var ringScale: CGFloat = 1
    @State private var now = Date()

    private var stats: FocusStats {
        FocusStatsCalculator.compute(sessions: sessions, events: events)
    }

    private var unlockUntil: Date? {
        let ts = max(
            SharedStore.store.double(forKey: SharedKeys.tempUnlockAllUntil),
            SharedStore.store.double(forKey: SharedKeys.tempUnlockUntil)
        )
        guard ts > now.timeIntervalSince1970 else { return nil }
        return Date(timeIntervalSince1970: ts)
    }

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "ellipsis")
                            .font(.body.weight(.light))
                            .foregroundStyle(VANASITheme.textWhisper)
                            .padding(20)
                    }
                }

                Spacer()

                VStack(spacing: 28) {
                    Button { toggleLock() } label: {
                        VANASILockRing(isLocked: lockManager.isLockEnabled)
                            .scaleEffect(ringScale)
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 8) {
                        Text(lockManager.isLockEnabled ? "Monk mode" : "Unlocked")
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(VANASITheme.textPrimary)

                        Text(subtitleLine)
                            .font(.subheadline.weight(.light))
                            .foregroundStyle(VANASITheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                VStack(spacing: 16) {
                    if lockManager.isLockEnabled {
                        Button("Request access · \(VANVASIConfig.unlockAllMinutes)m") {
                            showUnlockConfirm = true
                        }
                        .buttonStyle(VANASITextButton())
                    }

                    if !lockManager.allowedSelection.isValidAllowlist {
                        Button("Set free apps") { showAllowlistEditor = true }
                            .buttonStyle(VANASITextButton())
                    }

                    if stats.streakDays > 0 || stats.focusScore > 0 {
                        Text("\(stats.focusScore) focus · \(stats.streakDays)d streak")
                            .font(.caption2)
                            .foregroundStyle(VANASITheme.textWhisper)
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showAllowlistEditor) { AllowlistEditorView() }
        .sheet(isPresented: $showPINDisable) {
            PINEntryView(
                title: "PIN to disable",
                onSubmit: { pin in
                    if lockManager.disableLock(requirePIN: true, pin: pin, context: context) {
                        showPINDisable = false
                    }
                },
                onCancel: { showPINDisable = false }
            )
        }
        .fullScreenCover(isPresented: $showUnlockConfirm) {
            UnlockConfirmView(
                request: .unlockAll,
                onUnlocked: { showUnlockConfirm = false },
                onCancel: { showUnlockConfirm = false }
            )
            .environmentObject(lockManager)
        }
        .alert("Could not enable lock", isPresented: $showLockError) {
            Button("Free apps") { showAllowlistEditor = true }
            Button("OK", role: .cancel) {}
        } message: {
            Text(lockManager.lastError ?? "Select Phone, Messages, and VANVASI.")
        }
        .onAppear(perform: onAppearActions)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
            lockManager.restoreLockIfNeeded()
        }
    }

    private var subtitleLine: String {
        if let until = unlockUntil {
            return "Re-locks in \(remaining(until: until))"
        }
        return lockManager.isLockEnabled
            ? "Calls & messages only"
            : "Tap the ring to enable"
    }

    private func remaining(until: Date) -> String {
        let s = max(0, Int(until.timeIntervalSince(now)))
        let m = s / 60
        let sec = s % 60
        return m > 0 ? "\(m)m \(sec)s" : "\(sec)s"
    }

    private func toggleLock() {
        VANASIHaptics.medium()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            ringScale = 0.94
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                ringScale = 1
            }
        }

        if lockManager.isLockEnabled {
            if SharedStore.pinEnabled {
                showPINDisable = true
            } else {
                _ = lockManager.disableLock(requirePIN: false, context: context)
            }
        } else if lockManager.enableLock() {
            context.insert(LockEvent(action: LockEventAction.enabled))
            try? context.save()
        } else {
            showLockError = true
        }
    }

    private func onAppearActions() {
        lockManager.restoreLockIfNeeded()
        ScheduledLockManager.applySchedule()
        if SharedStore.store.string(forKey: SharedKeys.pendingUnlockScope) != nil {
            showUnlockConfirm = true
        }
    }
}

struct AllowlistEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var lockManager: MonkLockManager

    var body: some View {
        NavigationStack {
            ZStack {
                VANASIBackground()
                VStack(alignment: .leading, spacing: 12) {
                    Text("Phone · Messages · VANVASI")
                        .font(.footnote)
                        .foregroundStyle(VANASITheme.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    FamilyActivityPicker(selection: $lockManager.allowedSelection)
                    Spacer()
                }
            }
            .navigationTitle("Free apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(VANASITheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        lockManager.persistSelection()
                        if lockManager.isLockEnabled { _ = lockManager.enableLock() }
                        dismiss()
                    }
                    .foregroundStyle(VANASITheme.textPrimary)
                }
            }
            .toolbarBackground(VANASITheme.void, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
