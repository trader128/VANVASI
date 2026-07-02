import SwiftUI
import SwiftData

struct UnlockConfirmView: View {
    let request: UnlockRequest
    let onUnlocked: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.modelContext) private var context
    @State private var breathScale: CGFloat = 0.92
    @State private var appeared = false

    private var pricing: UnlockPricing { request.pricing }

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(VANASITheme.accent.opacity(0.3), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(breathScale)

                    Circle()
                        .fill(VANASITheme.accentSoft)
                        .frame(width: 100, height: 100)

                    Image(systemName: "lock.open")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(VANASITheme.accent)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        breathScale = 1.08
                    }
                }

                VStack(spacing: 10) {
                    Text("Pause.")
                        .font(.system(size: 34, weight: .light, design: .serif))
                        .foregroundStyle(VANASITheme.textPrimary)

                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(VANASITheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VANASICard {
                    VStack(spacing: 12) {
                        row("Access", pricing.title)
                        row("Duration", "\(pricing.minutes) min")
                        row("After", "Lock returns automatically")
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        VANASIHaptics.medium()
                        let service = UnlockService(lockManager: lockManager, context: context)
                        _ = service.grantUnlock(request: request)
                        onUnlocked()
                    } label: {
                        Text("Unlock for \(pricing.minutes) min")
                    }
                    .buttonStyle(VANASIPrimaryButton())

                    Button("Stay focused", action: onCancel)
                        .font(.subheadline)
                        .foregroundStyle(VANASITheme.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var headerSubtitle: String {
        switch request {
        case .singleApp(let label):
            return "Do you still need \(label)?"
        case .unlockAll:
            return "Do you still need your phone?"
        }
    }

    private func row(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key).foregroundStyle(VANASITheme.textSecondary)
            Spacer()
            Text(value).foregroundStyle(VANASITheme.textPrimary)
        }
        .font(.subheadline)
    }
}
