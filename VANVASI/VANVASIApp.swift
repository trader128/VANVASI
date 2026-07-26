import SwiftUI
import SwiftData
import UIKit

@main
struct VANVASIApp: App {
    @UIApplicationDelegateAdaptor(VANVASIAppDelegate.self) private var appDelegate
    @StateObject private var lockManager = MonkLockManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UnlockSession.self, LockEvent.self, PaymentRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        if let container = try? ModelContainer(for: schema, configurations: [config]) {
            return container
        }
        let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [fallback])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(lockManager)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    SharedStore.store.set(url.absoluteString, forKey: SharedKeys.pendingUnlockURL)
                    PendingUnlockRouter.signalPendingUnlockAvailable()
                }
                .task {
                    await NotificationPermission.requestIfNeeded()
                    ScheduledLockManager.applySchedule()
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var lockManager: MonkLockManager
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var pendingUnlock: UnlockRequest?

    var body: some View {
        Group {
            if onboardingComplete {
                HomeView()
            } else {
                OnboardingView(onComplete: { onboardingComplete = true })
            }
        }
        .fullScreenCover(item: $pendingUnlock) { request in
            UnlockConfirmView(
                request: request,
                onUnlocked: { pendingUnlock = nil },
                onCancel: { pendingUnlock = nil }
            )
            .environmentObject(lockManager)
        }
        .onAppear(perform: checkPendingUnlock)
        .onReceive(NotificationCenter.default.publisher(for: .vanasiOpenPendingUnlock)) { _ in
            checkPendingUnlock()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkPendingUnlock()
            lockManager.reconcileSharedLockState()
            Task { @MainActor in
                FocusPointsService.shared.consumePendingExtensionMerit()
            }
        }
    }

    private func checkPendingUnlock() {
        guard pendingUnlock == nil else { return }
        pendingUnlock = PendingUnlockRouter.consumePendingRequest()
    }
}

extension UnlockRequest: Identifiable {
    var id: String {
        switch self {
        case .singleApp(let label): return "app-\(label)"
        case .unlockAll: return "all"
        }
    }
}
