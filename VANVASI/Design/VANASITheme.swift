import SwiftUI

/// Ultra-minimal visual system — One Sec inspired. Void, whitespace, one hero.
enum VANASITheme {
    static let void = Color.black
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.38)
    static let textWhisper = Color.white.opacity(0.22)
    static let ringActive = Color.white.opacity(0.85)
    static let ringIdle = Color.white.opacity(0.12)
    static let ringFill = Color.white.opacity(0.04)
}

struct VANASIBackground: View {
    var body: some View {
        VANASITheme.void.ignoresSafeArea()
    }
}

// MARK: - Lock ring (home hero)

struct VANASILockRing: View {
    let isLocked: Bool
    var diameter: CGFloat = 200
    var lineWidth: CGFloat = 1.5

    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(isLocked ? VANASITheme.ringActive : VANASITheme.ringIdle, lineWidth: lineWidth)
                .frame(width: diameter, height: diameter)
                .scaleEffect(isLocked && pulse ? 1.02 : 1)
                .animation(
                    isLocked
                        ? .easeInOut(duration: 4).repeatForever(autoreverses: true)
                        : .default,
                    value: pulse
                )

            Circle()
                .fill(VANASITheme.ringFill)
                .frame(width: diameter - 28, height: diameter - 28)

            Image(systemName: isLocked ? "lock.fill" : "lock.open")
                .font(.system(size: diameter * 0.14, weight: .ultraLight))
                .foregroundStyle(isLocked ? VANASITheme.textPrimary : VANASITheme.textSecondary)
        }
        .onAppear { if isLocked { pulse = true } }
        .onChange(of: isLocked) { _, locked in pulse = locked }
    }
}

// MARK: - Buttons

struct VANASIPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(VANASITheme.textPrimary.opacity(configuration.isPressed ? 0.75 : 1))
            .foregroundStyle(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct VANASITextButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .foregroundStyle(VANASITheme.textSecondary.opacity(configuration.isPressed ? 0.6 : 1))
    }
}

struct VANASIMinimalRow: View {
    let title: String
    var subtitle: String? = nil
    var destructive = false

    var body: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
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
}

import UIKit
