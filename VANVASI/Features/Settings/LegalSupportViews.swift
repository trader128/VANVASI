import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text(VANVASILegal.privacyPolicyText)
                    .font(.footnote.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
                    .lineSpacing(6)

                Link("Open full policy on savarun.com", destination: VANVASILegal.privacyURL)
                    .font(.footnote)
                    .foregroundStyle(VANASITheme.textPrimary)
            }
            .padding(32)
        }
        .background(VANASIBackground())
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }
}

struct SupportContactView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Support")
                    .font(.title2.weight(.light))
                    .foregroundStyle(VANASITheme.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text(VANVASILegal.developerName)
                        .font(.body.weight(.medium))
                        .foregroundStyle(VANASITheme.textPrimary)
                    Link(VANVASILegal.supportEmail, destination: URL(string: "mailto:\(VANVASILegal.supportEmail)")!)
                    Link(VANVASILegal.supportPhone, destination: URL(string: "tel:\(VANVASILegal.supportPhoneTel)")!)
                }

                Text("We usually reply within 2-3 business days.")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)

                Link("Help and FAQ on savarun.com", destination: VANVASILegal.supportURL)
                    .font(.footnote)
                    .foregroundStyle(VANASITheme.textPrimary)
                    .padding(.top, 8)

                Text(VANVASILegal.madeInIndiaLine)
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .padding(.top, 24)
                Text("© \(VANVASILegal.copyrightLine)")
                    .font(.caption2)
                    .foregroundStyle(VANASITheme.textWhisper)
            }
            .padding(32)
        }
        .background(VANASIBackground())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }
}
