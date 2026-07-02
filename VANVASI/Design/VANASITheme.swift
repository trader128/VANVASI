import SwiftUI

/// Premium visual system — calm, dark, minimal (Opal / One Sec inspired).
enum VANASITheme {
    static let void = Color(red: 0.04, green: 0.04, blue: 0.05)
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let surfaceElevated = Color(red: 0.15, green: 0.15, blue: 0.18)
    static let textPrimary = Color(red: 0.96, green: 0.94, blue: 0.90)
    static let textSecondary = Color(red: 0.55, green: 0.54, blue: 0.52)
    static let accent = Color(red: 0.79, green: 0.66, blue: 0.38)
    static let accentSoft = Color(red: 0.79, green: 0.66, blue: 0.38).opacity(0.25)
    static let success = Color(red: 0.45, green: 0.78, blue: 0.58)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.12, green: 0.11, blue: 0.20),
            void
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct VANASIBackground: View {
    var body: some View {
        ZStack {
            VANASITheme.heroGradient.ignoresSafeArea()
            Circle()
                .fill(VANASITheme.accentSoft)
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(y: -120)
        }
    }
}

struct VANASIPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(VANASITheme.textPrimary.opacity(configuration.isPressed ? 0.85 : 1))
            .foregroundStyle(VANASITheme.void)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct VANASISecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(VANASITheme.surfaceElevated)
            .foregroundStyle(VANASITheme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

struct VANASICard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial.opacity(0.5))
            .background(VANASITheme.surface.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}

enum VANASIHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

import UIKit
