import SwiftUI

// MARK: - Colors & motion

enum VANASITheme {
    static let void = Color.black
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.42)
    static let textWhisper = Color.white.opacity(0.24)
    static let ringActive = Color.white.opacity(0.88)
    static let ringIdle = Color.white.opacity(0.14)
    static let ringFill = Color.white.opacity(0.06)
    static let accentGlow = Color.white.opacity(0.08)

    static let springSnappy = Animation.spring(response: 0.38, dampingFraction: 0.78)
    static let springSoft = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let easeAppear = Animation.easeOut(duration: 0.45)
}

struct VANASIBackground: View {
    var body: some View {
        ZStack {
            Color.black
            RadialGradient(
                colors: [
                    Color.white.opacity(0.07),
                    Color.black.opacity(0.2),
                    Color.black
                ],
                center: .center,
                startRadius: 40,
                endRadius: 420
            )
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Appear animation

struct VANASIAppear: ViewModifier {
    let delay: Double
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 14)
            .onAppear {
                withAnimation(VANASITheme.easeAppear.delay(delay)) {
                    visible = true
                }
            }
    }
}

extension View {
    func vanasiAppear(delay: Double = 0) -> some View {
        modifier(VANASIAppear(delay: delay))
    }
}

// MARK: - Lock ring (home hero)

struct VANASILockRing: View, Equatable {
    let isLocked: Bool
    var diameter: CGFloat = 200
    var lineWidth: CGFloat = 2

    static func == (lhs: VANASILockRing, rhs: VANASILockRing) -> Bool {
        lhs.isLocked == rhs.isLocked && lhs.diameter == rhs.diameter && lhs.lineWidth == rhs.lineWidth
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isLocked)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let wave = 0.5 + 0.5 * sin(t * 2 * .pi / 3.5)
            let ringScale = 1 + (isLocked ? 0.025 * wave : 0)
            let glowOpacity = isLocked ? 0.35 + 0.55 * wave : 0

            ZStack {
                if isLocked {
                    Circle()
                        .fill(VANASITheme.accentGlow)
                        .frame(width: diameter + 24, height: diameter + 24)
                        .blur(radius: 28)
                        .opacity(glowOpacity)
                }

                Circle()
                    .stroke(
                        isLocked ? VANASITheme.ringActive : VANASITheme.ringIdle,
                        lineWidth: lineWidth
                    )
                    .frame(width: diameter, height: diameter)
                    .scaleEffect(ringScale)

                Circle()
                    .fill(VANASITheme.ringFill)
                    .frame(width: diameter - 32, height: diameter - 32)

                Image(systemName: isLocked ? "lock.fill" : "lock.open")
                    .font(.system(size: diameter * 0.15, weight: .light))
                    .foregroundStyle(isLocked ? VANASITheme.textPrimary : VANASITheme.textSecondary)
            }
        }
        .animation(VANASITheme.springSoft, value: isLocked)
    }
}

// MARK: - Breathing ring (unlock pause)

struct VANASIBreathRing: View {
    var diameter: CGFloat = 168
    @State private var breathScale: CGFloat = 0.92

    var body: some View {
        ZStack {
            Circle()
                .stroke(VANASITheme.ringIdle, lineWidth: 1)
                .frame(width: diameter, height: diameter)
                .scaleEffect(breathScale)

            Circle()
                .stroke(VANASITheme.textWhisper, lineWidth: 0.5)
                .frame(width: diameter * 0.78, height: diameter * 0.78)
                .scaleEffect(2 - breathScale)

            Circle()
                .fill(VANASITheme.ringFill)
                .frame(width: diameter * 0.72, height: diameter * 0.72)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true)) {
                breathScale = 1.08
            }
        }
    }
}

// MARK: - Status chip

struct VANASIStatusChip: View {
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isLocked ? Color.white : Color.white.opacity(0.35))
                .frame(width: 6, height: 6)
            Text(isLocked ? "ACTIVE" : "OFF")
                .font(.caption2.weight(.semibold))
                .tracking(1.4)
        }
        .foregroundStyle(isLocked ? VANASITheme.textPrimary : VANASITheme.textSecondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(isLocked ? 0.1 : 0.05))
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .animation(VANASITheme.springSnappy, value: isLocked)
    }
}

// MARK: - Buttons

struct VANASIPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(VANASITheme.textPrimary.opacity(configuration.isPressed ? 0.78 : 1))
            .foregroundStyle(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(VANASITheme.springSnappy, value: configuration.isPressed)
    }
}

struct VANASISecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(VANASITheme.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.06 : 0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(VANASITheme.springSnappy, value: configuration.isPressed)
    }
}

struct VANASITextButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.medium))
            .foregroundStyle(VANASITheme.textSecondary.opacity(configuration.isPressed ? 0.5 : 1))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(VANASITheme.springSnappy, value: configuration.isPressed)
    }
}

struct VANASIIconButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .background(Circle().fill(Color.white.opacity(configuration.isPressed ? 0.08 : 0.04)))
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(VANASITheme.springSnappy, value: configuration.isPressed)
    }
}

// MARK: - Settings row

struct VANASIMinimalRow: View {
    let title: String
    var subtitle: String? = nil
    var destructive = false
    var showChevron = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(destructive ? Color.red.opacity(0.85) : VANASITheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(VANASITheme.textSecondary)
                }
            }
            Spacer(minLength: 8)
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VANASITheme.textWhisper)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

enum VANASIHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func lockEngaged() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9)
    }
}

import UIKit
