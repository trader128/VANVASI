import SwiftUI
import FamilyControls
import Combine

struct HomeView: View {
    @EnvironmentObject private var lockManager: MonkLockManager
    @State private var showUnlockConfirm = false
    @State private var showSettings = false
    @State private var showAllowlistEditor = false
    @State private var showLockError = false
    @State private var now = Date()

    private var unlockUntil: Date? {
        let ts = max(
            SharedStore.store.double(forKey: "tempUnlockAllUntil"),
            SharedStore.store.double(forKey: "tempUnlockUntil")
        )
        guard ts > now.timeIntervalSince1970 else { return nil }
        return Date(timeIntervalSince1970: ts)
    }

    var body: some View {
        ZStack {
            VANASIBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    topBar
                    lockHero
                    if let until = unlockUntil {
                        unlockActiveCard(until: until)
                    }
                    statsRow
                    lockCard
                    if !lockManager.allowedSelection.isValidAllowlist {
                        allowlistWarning
                    }
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showAllowlistEditor) { AllowlistEditorView() }
        .fullScreenCover(isPresented: $showUnlockConfirm) {
            UnlockConfirmView(
                request: .unlockAll,
                onUnlocked: { showUnlockConfirm = false },
                onCancel: { showUnlockConfirm = false }
            )
            .environmentObject(lockManager)
        }
        .alert("Could not enable lock", isPresented: $showLockError) {
            Button("Edit free apps") { showAllowlistEditor = true }
            Button("OK", role: .cancel) {}
        } message: {
            Text(lockManager.lastError ?? "Select Phone, Messages, and VANVASI.")
        }
        .onAppear {
            lockManager.restoreLockIfNeeded()
            if SharedStore.store.string(forKey: "pendingUnlockScope") != nil {
                showUnlockConfirm = true
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { tick in
            now = tick
            lockManager.restoreLockIfNeeded()
        }
    }

    private func unlockActiveCard(until: Date) -> some View {
        VANASICard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Temporary access")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(VANASITheme.textPrimary)
                    Text("Re-locks in \(remaining(until: until))")
                        .font(.caption)
                        .foregroundStyle(VANASITheme.accent)
                }
                Spacer()
                Image(systemName: "hourglass")
                    .foregroundStyle(VANASITheme.accent.opacity(0.8))
            }
        }
    }

    private func remaining(until: Date) -> String {
        let s = max(0, Int(until.timeIntervalSince(now)))
        let m = s / 60
        let sec = s % 60
        return m > 0 ? "\(m)m \(sec)s" : "\(sec)s"
    }

    private var topBar: some View {
        HStack {
            Text("VANVASI")
                .font(.caption.weight(.semibold))
                .tracking(3)
                .foregroundStyle(VANASITheme.accent)
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(VANASITheme.textSecondary)
            }
        }
        .padding(.top, 8)
    }

    private var lockHero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(
                        lockManager.isLockEnabled ? VANASITheme.accent : Color.white.opacity(0.1),
                        lineWidth: 2
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(lockManager.isLockEnabled ? VANASITheme.accentSoft : Color.white.opacity(0.04))
                    .frame(width: 96, height: 96)

                Image(systemName: lockManager.isLockEnabled ? "lock.fill" : "lock.open")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(lockManager.isLockEnabled ? VANASITheme.accent : VANASITheme.textSecondary)
            }

            Text(lockManager.isLockEnabled ? "Monk mode active" : "Monk mode off")
                .font(.title2.weight(.light))
                .foregroundStyle(VANASITheme.textPrimary)

            Text("Calls & messages stay open")
                .font(.caption)
                .foregroundStyle(VANASITheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statPill(value: "\(lockManager.allowedSelection.allowedAppCount)", label: "Free apps")
            statPill(value: "\(VANVASIConfig.singleAppMinutes)m", label: "Unlock window")
            statPill(value: lockManager.isLockEnabled ? "ON" : "OFF", label: "Shield")
        }
    }

    private func statPill(value: String, label: String) -> some View {
        VANASICard {
            VStack(spacing: 4) {
                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VANASITheme.textPrimary)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var lockCard: some View {
        VANASICard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("VANVASI Lock")
                        .font(.headline)
                        .foregroundStyle(VANASITheme.textPrimary)
                    Text(lockManager.isLockEnabled ? "Distractions shielded" : "Tap to protect focus")
                        .font(.caption)
                        .foregroundStyle(VANASITheme.textSecondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { lockManager.isLockEnabled },
                    set: { enabled in
                        VANASIHaptics.light()
                        if enabled {
                            if !lockManager.enableLock() { showLockError = true }
                        } else {
                            lockManager.disableLock()
                        }
                    }
                ))
                .labelsHidden()
                .tint(VANASITheme.accent)
            }
        }
    }

    private var allowlistWarning: some View {
        Button { showAllowlistEditor = true } label: {
            Text("Set free apps: Phone, Messages, VANVASI")
                .font(.footnote)
                .foregroundStyle(VANASITheme.accent)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showUnlockConfirm = true
            } label: {
                HStack {
                    Text("Request full access")
                    Spacer()
                    Text("\(VANVASIConfig.unlockAllMinutes) min")
                        .foregroundStyle(VANASITheme.textSecondary)
                }
            }
            .buttonStyle(VANASISecondaryButton())
            .disabled(!lockManager.isLockEnabled)
            .opacity(lockManager.isLockEnabled ? 1 : 0.45)

            Button { showAllowlistEditor = true } label: {
                Text("Edit free apps")
            }
            .font(.footnote)
            .foregroundStyle(VANASITheme.textSecondary)
        }
    }
}

struct AllowlistEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var lockManager: MonkLockManager

    var body: some View {
        NavigationStack {
            ZStack {
                VANASITheme.void.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Phone · Messages · VANVASI must stay free.")
                        .font(.footnote)
                        .foregroundStyle(VANASITheme.textSecondary)
                    FamilyActivityPicker(selection: $lockManager.allowedSelection)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Free apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        lockManager.persistSelection()
                        if lockManager.isLockEnabled { _ = lockManager.enableLock() }
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
