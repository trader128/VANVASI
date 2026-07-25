import SwiftUI

struct HowItWorksView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text("VANVASI helps you stay focused by locking your iPhone to calls and messages until you choose to unlock with intention.")
                    .font(.subheadline.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
                    .lineSpacing(4)

                step(1, "Turn on monk mode", "Tap the lock ring on the home screen. Phone, Messages, and VANVASI stay available.")

                step(2, "Choose free apps", "In Settings → Free apps, select Phone, Messages, and VANVASI so you are never locked out.")

                step(3, "Blocked apps show a shield", "When you open another app, Apple’s Screen Time shield appears with Pause and Unlock.")

                step(4, "Unlock with intention", "Complete the breathing pause in VANVASI, then get timed access. Monk mode returns automatically when the timer ends.")

                step(5, "End lock anytime", "Tap ⋯ → End lock. Optional PIN adds extra protection against turning lock off.")

                Text("VANVASI is for adults who choose to limit their own device. It is not parental monitoring.")
                    .font(.caption)
                    .foregroundStyle(VANASITheme.textWhisper)
                    .padding(.top, 8)
            }
            .padding(32)
        }
        .background(VANASIBackground())
        .navigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }

    private func step(_ number: Int, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.black)
                .frame(width: 24, height: 24)
                .background(VANASITheme.textPrimary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(VANASITheme.textPrimary)
                Text(body)
                    .font(.footnote.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)
                    .lineSpacing(3)
            }
        }
    }
}
