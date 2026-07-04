import Foundation

protocol PaymentGateway {
    func purchaseUnlock(for request: UnlockRequest) async throws -> PaymentResult
    func restorePurchases() async throws
}

struct PaymentResult {
    let productID: String
    let transactionID: String
    let amountLabel: String
    let durationMinutes: Int
    let unlockLabel: String
}

enum PaymentError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not available."
        case .userCancelled: return "Purchase cancelled."
        case .pending: return "Purchase pending approval."
        case .failed(let msg): return msg
        }
    }
}
