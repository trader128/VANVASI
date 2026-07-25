import SwiftUI

struct MeritGuideView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Earn merit for choices that protect your focus. Everything stays on your device.")
                    .font(.subheadline.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
                    .lineSpacing(4)

                rule("Monk mode on", "+\(VANVASIConfig.pointsLockEngaged)", "Turn on the lock ring")
                rule("Protected time", "+\(VANVASIConfig.pointsPerFiveMinutesLocked) / 5 min", "Stay in monk mode")
                rule("Stay focused", "+\(VANVASIConfig.pointsStayFocused)", "Decline unlock on the pause screen")
                rule("Daily streak", "+\(VANVASIConfig.pointsStreakDayBonus)+", "Lock at least once per day")

                VStack(alignment: .leading, spacing: 8) {
                    Text("LEVELS")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(VANASITheme.textWhisper)
                    Text("Every \(VANVASIConfig.pointsPerLevel) merit levels you up — Novice → Seeker → Monk → Anchor → Master.")
                        .font(.footnote.weight(.light))
                        .foregroundStyle(VANASITheme.textSecondary)
                        .lineSpacing(3)
                }

                Text("Merit rewards discipline, not unlocking apps.")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)
            }
            .padding(32)
        }
        .background(VANASIBackground())
        .navigationTitle("Merit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }

    private func rule(_ title: String, _ points: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(points)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(VANASITheme.textPrimary)
                .clipShape(Capsule(style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(VANASITheme.textPrimary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textSecondary)
            }
        }
    }
}
