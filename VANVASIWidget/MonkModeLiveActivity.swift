import ActivityKit
import SwiftUI
import WidgetKit

struct MonkModeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MonkModeActivityAttributes.self) { context in
            lockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.mode == .monkModeActive ? "lock.fill" : "lock.open")
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.center) {
                    expandedCenter(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.meritPoints)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
            } compactLeading: {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.white)
            } compactTrailing: {
                compactTrailing(context: context)
            } minimal: {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<MonkModeActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: context.state.mode == .monkModeActive ? "lock.fill" : "timer")
                .font(.title3.weight(.light))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.mode == .monkModeActive ? "Monk mode active" : "Unlock window")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                if context.state.mode == .unlockWindow, let end = context.state.relockAt {
                    Text("Re-locks \(end, style: .timer)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .monospacedDigit()
                } else {
                    Text("\(context.state.meritPoints) merit · calls & messages only")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func expandedCenter(context: ActivityViewContext<MonkModeActivityAttributes>) -> some View {
        if context.state.mode == .unlockWindow, let end = context.state.relockAt {
            Text(end, style: .timer)
                .font(.title3.monospacedDigit())
                .foregroundStyle(.white)
        } else {
            Text("Monk mode")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private func compactTrailing(context: ActivityViewContext<MonkModeActivityAttributes>) -> some View {
        if context.state.mode == .unlockWindow, let end = context.state.relockAt {
            Text(end, style: .timer)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white.opacity(0.9))
        } else {
            Text("ON")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}
