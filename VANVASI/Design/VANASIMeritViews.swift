import SwiftUI

struct VANASIMeritCard: View {
    let total: Int
    let level: Int
    let levelTitle: String
    let progress: Double
    let streakDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MERIT")
                        .font(.caption2.weight(.semibold))
                        .tracking(2)
                        .foregroundStyle(VANASITheme.textWhisper)
                    Text("\(total)")
                        .font(.system(size: 34, weight: .light, design: .rounded))
                        .foregroundStyle(VANASITheme.textPrimary)
                        .contentTransition(.numericText())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LV \(level)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VANASITheme.textSecondary)
                    Text(levelTitle)
                        .font(.caption2)
                        .foregroundStyle(VANASITheme.textWhisper)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * progress))
                        .animation(VANASITheme.springSoft, value: progress)
                }
            }
            .frame(height: 4)

            if streakDays > 0 {
                Text("\(streakDays)-day streak · keep monk mode alive")
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textWhisper)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }
}

struct VANASIPointsToast: View {
    let gain: FocusPointsService.PointGain

    @State private var visible = false
    @State private var floatUp = false

    var body: some View {
        VStack(spacing: 4) {
            Text("+\(gain.amount)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(VANASITheme.textPrimary)
            Text(gain.reason)
                .font(.caption)
                .foregroundStyle(VANASITheme.textSecondary)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.12))
                .shadow(color: .white.opacity(0.15), radius: 20)
        )
        .scaleEffect(visible ? 1 : 0.6)
        .opacity(visible ? 1 : 0)
        .offset(y: floatUp ? -8 : 12)
        .onAppear {
            withAnimation(VANASITheme.springSnappy) { visible = true }
            withAnimation(.easeOut(duration: 1.2).delay(0.15)) { floatUp = true }
        }
    }
}
