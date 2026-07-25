import SwiftUI
import SwiftData

struct UnlockConfirmView: View {
    let request: UnlockRequest
    let onUnlocked: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var lockManager: MonkLockManager
    @Environment(\.modelContext) private var context
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    private var pricing: UnlockPricing { request.pricing }
    private var paymentsOn: Bool { VANVASIConfig.showPaymentsInSettings && SharedStore.paymentsEnabled }

    var body: some View {
        ZStack {
            VANASIBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(VANASITheme.textSecondary)
                    }
                    .buttonStyle(VANASIIconButton())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .vanasiAppear()

                Spacer()

                VANASIBreathRing()
                    .vanasiAppear(delay: 0.08)

                Spacer().frame(height: 44)

                Text("Pause.")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(VANASITheme.textPrimary)
                    .vanasiAppear(delay: 0.14)

                Text(headerSubtitle)
                    .font(.subheadline.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 40)
                    .vanasiAppear(delay: 0.2)

                Text("You already paused at the shield.")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .padding(.top, 8)
                    .vanasiAppear(delay: 0.22)

                Text("\(pricing.minutes) minutes · then lock returns")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .padding(.top, 20)
                    .vanasiAppear(delay: 0.26)

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
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                VStack(spacing: 16) {
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

                    Button("Stay focused") {
                        FocusPointsService.shared.recordStayFocused()
                        onCancel()
                    }
                        .buttonStyle(VANASITextButton())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .vanasiAppear(delay: 0.32)
            }
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
        return "Unlock for \(pricing.minutes) min"
    }

    private var headerSubtitle: String {
        switch request {
        case .singleApp(let label): return "Still need \(label)?"
        case .unlockAll: return "Still need full access?"
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
                    withAnimation(VANASITheme.springSoft) {
                        purchaseError = error.localizedDescription
                    }
                    return
                }
            }

            let service = UnlockService(lockManager: lockManager, context: context)
            _ = service.grantUnlock(request: request, wasPaid: wasPaid)
            VANASIHaptics.success()
            onUnlocked()
        }
    }
}
