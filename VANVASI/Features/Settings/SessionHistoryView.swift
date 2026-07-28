import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(sort: \UnlockSession.startedAt, order: .reverse) private var sessions: [UnlockSession]
    @Query(sort: \LockEvent.date, order: .reverse) private var events: [LockEvent]

    var body: some View {
        ScrollView(showsIndicators: false) {
            if sessions.isEmpty && events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 36, weight: .ultraLight))
                        .foregroundStyle(VANASITheme.textWhisper)
                    Text("No history yet")
                        .font(.headline.weight(.light))
                        .foregroundStyle(VANASITheme.textPrimary)
                    Text("Unlocks and lock events appear here after you use monk mode.")
                        .font(.footnote)
                        .foregroundStyle(VANASITheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
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

                    if !events.isEmpty {
                        section("Lock events") {
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
                }
                .padding(24)
            }
        }
        .background(VANASIBackground())
        .navigationTitle("History")
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
        case LockEventAction.enabled: return "Monk mode on"
        case LockEventAction.disabled: return "Monk mode off"
        case LockEventAction.emergencyExit: return "Lock ended"
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
