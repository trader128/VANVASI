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

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        expiresAt: Date,
        scope: String,
        coinCost: Int = 0,
        label: String
    ) {
        self.id = id
        self.startedAt = startedAt
        self.expiresAt = expiresAt
        self.scope = scope
        self.coinCost = coinCost
        self.label = label
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
