import Foundation
import StoreKit

@MainActor
final class StoreKitPaymentGateway: PaymentGateway {
    static let shared = StoreKitPaymentGateway()

    private init() {}

    func purchaseUnlock(for request: UnlockRequest) async throws -> PaymentResult {
        let productID: String
        switch request {
        case .singleApp: productID = VANVASIConfig.productIDSingleApp
        case .unlockAll: productID = VANVASIConfig.productIDUnlockAll
        }

        let products = try await Product.products(for: [productID])
        guard let product = products.first else { throw PaymentError.productNotFound }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return PaymentResult(
                productID: product.id,
                transactionID: String(transaction.id),
                amountLabel: product.displayPrice,
                durationMinutes: request.pricing.minutes,
                unlockLabel: request.pricing.title
            )
        case .userCancelled:
            throw PaymentError.userCancelled
        case .pending:
            throw PaymentError.pending
        @unknown default:
            throw PaymentError.failed("Unknown purchase result.")
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw PaymentError.failed("Transaction could not be verified.")
        case .verified(let value): return value
        }
    }
}
