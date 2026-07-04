import SwiftUI
import SwiftData

struct UnlockConfirmView: View {
    let request: UnlockRequest
    let onUnlocked: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.modelContext) private var context
    @State private var breathScale: CGFloat = 0.94
    @State private var appeared = false
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    private var pricing: UnlockPricing { request.pricing }
    private var paymentsOn: Bool { SharedStore.paymentsEnabled }

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(VANASITheme.ringIdle, lineWidth: 1)
                        .frame(width: 160, height: 160)
                        .scaleEffect(breathScale)

                    Circle()
                        .fill(VANASITheme.ringFill)
                        .frame(width: 130, height: 130)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        breathScale = 1.06
                    }
                }

                Spacer().frame(height: 48)

                Text("Pause.")
                    .font(.system(size: 40, weight: .ultraLight))
                    .foregroundStyle(VANASITheme.textPrimary)

                Text(headerSubtitle)
                    .font(.subheadline.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 40)

                Text("\(pricing.minutes) minutes · then lock returns")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .padding(.top, 20)

                if paymentsOn {
                    Text(priceLabel)
                        .font(.caption)
                        .foregroundStyle(VANASITheme.textSecondary)
                        .padding(.top, 8)
                }

                if let purchaseError {
                    Text(purchaseError)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .padding(.top, 12)
                }

                Spacer()

                VStack(spacing: 20) {
                    Button { performUnlock() } label: {
                        Group {
                            if isPurchasing {
                                ProgressView().tint(.black)
                            } else {
                                Text(unlockButtonTitle)
                            }
                        }
                    }
                    .buttonStyle(VANASIPrimaryButton())

                    Button("Stay focused", action: onCancel)
                        .buttonStyle(VANASITextButton())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var priceLabel: String {
        switch request {
        case .singleApp: return VANVASIConfig.singleAppPriceLabel
        case .unlockAll: return VANVASIConfig.unlockAllPriceLabel
        }
    }

    private var unlockButtonTitle: String {
        if paymentsOn { return "Pay \(priceLabel)" }
        return "Unlock"
    }

    private var headerSubtitle: String {
        switch request {
        case .singleApp(let label): return "Do you still need \(label)?"
        case .unlockAll: return "Do you still need your phone?"
        }
    }

    private func performUnlock() {
        VANASIHaptics.medium()
        purchaseError = nil

        Task {
            isPurchasing = true
            defer { isPurchasing = false }

            var wasPaid = false
            if paymentsOn {
                do {
                    let result = try await StoreKitPaymentGateway.shared.purchaseUnlock(for: request)
                    wasPaid = true
                    context.insert(PaymentRecord(
                        productID: result.productID,
                        transactionID: result.transactionID,
                        amountLabel: result.amountLabel,
                        unlockLabel: result.unlockLabel,
                        durationMinutes: result.durationMinutes
                    ))
                } catch PaymentError.userCancelled {
                    return
                } catch {
                    purchaseError = error.localizedDescription
                    return
                }
            }

            let service = UnlockService(lockManager: lockManager, context: context)
            _ = service.grantUnlock(request: request, wasPaid: wasPaid)
            onUnlocked()
        }
    }
}
