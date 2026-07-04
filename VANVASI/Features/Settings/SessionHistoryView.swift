import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(sort: \UnlockSession.startedAt, order: .reverse) private var sessions: [UnlockSession]
    @Query(sort: \LockEvent.date, order: .reverse) private var events: [LockEvent]
    @Query(sort: \PaymentRecord.date, order: .reverse) private var payments: [PaymentRecord]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                if !sessions.isEmpty {
                    section("Unlocks") {
                        ForEach(sessions) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.label)
                                        .font(.subheadline)
                                        .foregroundStyle(VANASITheme.textPrimary)
                                    Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(VANASITheme.textWhisper)
                                }
                                Spacer()
                                Text("\(session.pricingMinutes)m")
                                    .font(.caption)
                                    .foregroundStyle(VANASITheme.textSecondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                section("Events") {
                    ForEach(events) { event in
                        HStack {
                            Text(eventLabel(event.action))
                                .font(.subheadline)
                                .foregroundStyle(VANASITheme.textPrimary)
                            Spacer()
                            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(VANASITheme.textWhisper)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(24)
        }
        .background(VANASIBackground())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }

    private func section<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .tracking(2)
                .foregroundStyle(VANASITheme.textWhisper)
            content()
        }
    }

    private func eventLabel(_ action: String) -> String {
        switch action {
        case LockEventAction.enabled: return "Enabled"
        case LockEventAction.disabled: return "Disabled"
        case LockEventAction.emergencyExit: return "Emergency exit"
        case LockEventAction.scheduledEnable: return "Scheduled on"
        case LockEventAction.scheduledDisable: return "Scheduled off"
        case LockEventAction.focusSyncEnable: return "Shortcut"
        default: return action
        }
    }
}

private extension UnlockSession {
    var pricingMinutes: Int {
        scope == UnlockScope.unlockAll.rawValue
            ? VANVASIConfig.unlockAllMinutes
            : VANVASIConfig.singleAppMinutes
    }
}
