import SwiftUI
import FamilyControls
import Combine
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.modelContext) private var context
    @ObservedObject private var points = FocusPointsService.shared
    @Query(sort: \UnlockSession.startedAt, order: .reverse) private var sessions: [UnlockSession]
    @Query(sort: \LockEvent.date, order: .reverse) private var events: [LockEvent]

    @State private var homeUnlockRequest: UnlockRequest?
    @State private var showSettings = false
    @State private var showAllowlistEditor = false
    @State private var showLockError = false
    @State private var showPINDisable = false
    @State private var ringScale: CGFloat = 1
    @State private var sessionDurationMinutes = MonkSessionUntilManager.preferenceDurationMinutes
    @State private var homeTick = 0

    private var stats: FocusStats {
        FocusStatsCalculator.compute(sessions: sessions, events: events)
    }

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(spacing: 0) {
                headerBar
                ScrollView(showsIndicators: false) {
                    homeScrollContent
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
        .sheet(isPresented: $showAllowlistEditor) {
            AllowlistEditorView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
        .sheet(isPresented: $showPINDisable) {
            PINEntryView(
                title: "PIN to disable",
                onSubmit: { pin in
                    lockManager.disableLock(requirePIN: true, pin: pin, context: context)
                },
                onCancel: { showPINDisable = false }
            )
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $homeUnlockRequest) { request in
            UnlockConfirmView(
                request: request,
                flow: .openedFromHome,
                onUnlocked: { homeUnlockRequest = nil },
                onCancel: { homeUnlockRequest = nil }
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
            homeTick += 1
            processMonkSessionUntilExpiry()
            if homeTick.isMultiple(of: 5) {
                lockManager.reconcileSharedLockState()
                lockManager.restoreLockIfNeeded()
                if lockManager.isLockEnabled {
                    points.syncLockedTimeRewards()
                }
            }
            if homeTick.isMultiple(of: 15), lockManager.isLockEnabled {
                LiveActivityManager.syncMonkModeLocked(meritPoints: points.total)
            }
        }
        .onChange(of: lockManager.isLockEnabled) { wasLocked, isLocked in
            points.resetSessionBucketsIfNeeded(wasLocked: wasLocked, isLocked: isLocked)
            if isLocked {
                LiveActivityManager.syncMonkModeLocked(meritPoints: points.total)
            } else {
                LiveActivityManager.endAll()
            }
        }
        .onChange(of: stats.streakDays) { _, streak in
            points.syncStreakBonus(streakDays: streak)
        }
        .onChange(of: points.recentGain?.id) { _, id in
            if id != nil { VANASIHaptics.success() }
        }
    }

    private var headerBar: some View {
        HStack {
            VANASIStatusChip(isLocked: lockManager.isLockEnabled)
                .vanasiAppear(delay: 0.05)
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.body.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
            }
            .buttonStyle(VANASIIconButton())
            .vanasiAppear(delay: 0.08)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var homeScrollContent: some View {
        VStack(spacing: 24) {
            lockHeroBlock

            if lockManager.isLockEnabled {
                lockedActionsBlock
            } else {
                sessionDurationSection
            }

            homeFooterBlock
        }
    }

    private var lockHeroBlock: some View {
        VStack(spacing: 28) {
            Button { toggleLock() } label: {
                VANASILockRing(isLocked: lockManager.isLockEnabled)
                    .equatable()
                    .scaleEffect(ringScale)
            }
            .buttonStyle(.plain)
            .vanasiAppear(delay: 0.12)

            VStack(spacing: 10) {
                Text(lockManager.isLockEnabled ? "Monk mode" : "Unlocked")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(VANASITheme.textPrimary)

                HomeMonkStatusSubtitle(isLocked: lockManager.isLockEnabled)
            }
            .vanasiAppear(delay: 0.2)

            meritPointsToastSlot
                .animation(.easeInOut(duration: 0.28), value: points.recentGain?.id)

            VANASIMeritCard(
                total: points.total,
                level: points.level,
                levelTitle: points.levelTitle,
                progress: points.progressInLevel,
                streakDays: stats.streakDays
            )
            .padding(.horizontal, 28)
            .padding(.bottom, 2)
        }
    }

    private var lockedActionsBlock: some View {
        VStack(spacing: 12) {
            Button("Request access · \(VANVASIConfig.unlockAllMinutes)m break") {
                VANASIHaptics.light()
                homeUnlockRequest = .unlockAll
            }
            .buttonStyle(VANASISecondaryButton())
            .padding(.horizontal, 32)

            if MonkSessionUntilManager.activeUntil != nil {
                Text("Timed breaks last up to \(VANVASIConfig.unlockAllMinutes) minutes, then monk mode returns.")
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
        }
        .padding(.top, 8)
    }

    private var homeFooterBlock: some View {
        VStack(spacing: 14) {
            if !lockManager.allowedSelection.isValidAllowlist {
                Button("Set free apps") { showAllowlistEditor = true }
                    .buttonStyle(VANASITextButton())
            }

            if ScheduledLockManager.isEnabled {
                Text("Auto monk mode · \(ScheduledLockManager.formattedWindow())")
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textWhisper)
            } else if !lockManager.isLockEnabled {
                Button {
                    showSettings = true
                } label: {
                    Text("Schedule daily monk mode")
                        .font(.caption)
                        .foregroundStyle(VANASITheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            if stats.focusScore > 0, !lockManager.isLockEnabled {
                Text("Habit score · \(stats.focusScore)/100")
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textWhisper)
            }

            Text("Self-imposed focus · Not parental controls")
                .font(.caption2)
                .foregroundStyle(VANASITheme.textWhisper.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, lockManager.isLockEnabled ? 8 : 0)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var meritPointsToastSlot: some View {
        if let gain = points.recentGain {
            VANASIPointsToast(gain: gain) {
                points.clearRecentGain()
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .id(gain.id)
        } else {
            Color.clear.frame(height: 0)
        }
    }

    private var sessionDurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monk mode length")
                .font(.subheadline)
                .foregroundStyle(VANASITheme.textPrimary)
            Text("Pick how long monk mode runs after you lock.")
                .font(.caption2)
                .foregroundStyle(VANASITheme.textWhisper)
                .lineSpacing(3)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MonkSessionUntilManager.durationOptions, id: \.self) { minutes in
                        durationChip(minutes)
                    }
                }
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func durationChip(_ minutes: Int) -> some View {
        let selected = sessionDurationMinutes == minutes
        return Button {
            VANASIHaptics.light()
            sessionDurationMinutes = minutes
            MonkSessionUntilManager.preferenceDurationMinutes = minutes
        } label: {
            Text(MonkSessionUntilManager.label(for: minutes))
                .font(.caption.weight(selected ? .semibold : .regular))
                .foregroundStyle(selected ? Color.black : VANASITheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(selected ? VANASITheme.textPrimary : VANASITheme.ringFill)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggleLock() {
        withAnimation(VANASITheme.springSnappy) {
            ringScale = 0.92
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(VANASITheme.springSoft) {
                ringScale = 1
            }
        }

        if lockManager.isLockEnabled {
            VANASIHaptics.light()
            requestDisableMonkMode()
        } else if lockManager.enableLock() {
            VANASIHaptics.lockEngaged()
            MonkSessionUntilManager.preferenceDurationMinutes = sessionDurationMinutes
            points.recordLockEngaged()
            LiveActivityManager.syncMonkModeLocked(meritPoints: points.total)
            context.insert(LockEvent(action: LockEventAction.enabled))
            try? context.save()
        } else {
            VANASIHaptics.medium()
            showLockError = true
        }
    }

    private func requestDisableMonkMode() {
        guard EndLockProtectionStore.isRequired else {
            _ = lockManager.disableLock(requirePIN: false, context: context)
            return
        }
        switch EndLockProtectionStore.mode {
        case .fourDigitPIN:
            showPINDisable = true
        case .faceID, .devicePasscode:
            Task {
                if await EndLockProtection.authenticateSystem() {
                    _ = lockManager.disableLock(systemAuthOK: true, context: context)
                }
            }
        case .none:
            _ = lockManager.disableLock(requirePIN: false, context: context)
        }
    }

    private func onAppearActions() {
        lockManager.reconcileSharedLockState()
        lockManager.restoreLockIfNeeded()
        ScheduledLockManager.applySchedule()
        points.syncLockedTimeRewards()
        points.syncStreakBonus(streakDays: stats.streakDays)
        points.consumePendingExtensionMerit()
        LiveActivityManager.syncMonkModeLocked(meritPoints: points.total)
        processMonkSessionUntilExpiry()
        sessionDurationMinutes = MonkSessionUntilManager.preferenceDurationMinutes
    }

    private func processMonkSessionUntilExpiry() {
        if SharedStore.store.bool(forKey: SharedKeys.pendingMonkSessionEnded) {
            SharedStore.store.set(false, forKey: SharedKeys.pendingMonkSessionEnded)
            lockManager.reconcileSharedLockState()
            context.insert(LockEvent(action: LockEventAction.scheduledDisable))
            try? context.save()
        }
        guard lockManager.isLockEnabled, MonkSessionUntilManager.shouldEndSessionNow() else { return }
        _ = lockManager.disableLock(requirePIN: false, context: context)
        context.insert(LockEvent(action: LockEventAction.scheduledDisable))
        try? context.save()
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
                    Text(VANVASIShieldCopy.iosMayStayAvailableShort)
                        .font(.caption2)
                        .foregroundStyle(VANASITheme.textWhisper)
                        .padding(.horizontal, 20)
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
                        VANASIHaptics.success()
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
