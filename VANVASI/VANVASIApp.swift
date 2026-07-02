import SwiftUI
import SwiftData
import FamilyControls
import UIKit

@main
struct VANVASIApp: App {
    @StateObject private var lockManager = MonkLockManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UnlockSession.self, LockEvent.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(lockManager)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    SharedStore.store.set(url.absoluteString, forKey: "pendingUnlockURL")
                }
                .task {
                    await NotificationPermission.requestIfNeeded()
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkPendingUnlock()
        }
    }

    private func checkPendingUnlock() {
        if let urlString = SharedStore.store.string(forKey: "pendingUnlockURL"),
           let url = URL(string: urlString) {
            SharedStore.store.removeObject(forKey: "pendingUnlockURL")
            pendingUnlock = UnlockDeepLinkHandler.request(from: url)
            return
        }
        if let pending = UnlockDeepLinkHandler.pendingFromShield() {
            pendingUnlock = pending
        }
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
