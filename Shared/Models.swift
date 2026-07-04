import Foundation
import SwiftData

@Model
final class UnlockSession {
    var id: UUID
    var startedAt: Date
    var expiresAt: Date
    var scope: String
    var coinCost: Int
    var label: String
    var wasPaid: Bool

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        expiresAt: Date,
        scope: String,
        coinCost: Int = 0,
        label: String,
        wasPaid: Bool = false
    ) {
        self.id = id
        self.startedAt = startedAt
        self.expiresAt = expiresAt
        self.scope = scope
        self.coinCost = coinCost
        self.label = label
        self.wasPaid = wasPaid
    }

    var isActive: Bool { expiresAt > .now }
}

@Model
final class LockEvent {
    var id: UUID
    var date: Date
    var action: String
    var note: String?

    init(id: UUID = UUID(), date: Date = .now, action: String, note: String? = nil) {
        self.id = id
        self.date = date
        self.action = action
        self.note = note
    }
}

@Model
final class PaymentRecord {
    var id: UUID
    var date: Date
    var productID: String
    var transactionID: String
    var amountLabel: String
    var unlockLabel: String
    var durationMinutes: Int

    init(
        id: UUID = UUID(),
        date: Date = .now,
        productID: String,
        transactionID: String,
        amountLabel: String,
        unlockLabel: String,
        durationMinutes: Int
    ) {
        self.id = id
        self.date = date
        self.productID = productID
        self.transactionID = transactionID
        self.amountLabel = amountLabel
        self.unlockLabel = unlockLabel
        self.durationMinutes = durationMinutes
    }
}

struct FocusStats {
    var unlockCount: Int
    var streakDays: Int
    var protectedMinutes: Int
    var focusScore: Int

    static let empty = FocusStats(unlockCount: 0, streakDays: 0, protectedMinutes: 0, focusScore: 0)
}
