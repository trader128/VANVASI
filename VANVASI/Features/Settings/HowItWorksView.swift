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

                step(2, "Set session length", "Choose 15m, 30m, 1h, or 2h before you lock. Monk mode ends automatically when the session finishes unless you end it sooner.")

                step(3, "Choose free apps", "In Settings → Free apps, select Phone, Messages, and VANVASI so you are never locked out.")

                step(4, "Some apps stay open (iOS)", "Watch, Files, and Safari may never lock — Apple’s Screen Time limit. VANVASI still shields most other apps.")

                step(5, "Blocked apps show a shield", "You see Pause. Tap Open VANVASI to continue with intention, or Stay focused for merit.")

                step(6, "Unlock with intention", "Complete the pause in VANVASI, then get timed access. Monk mode returns when the timer ends.")

                step(7, "End lock anytime", "Settings → End lock. Optional: Off, 4-digit PIN, Face ID, or iPhone passcode.")

                step(8, "Earn merit", "Points for monk mode, protected minutes, streaks, and Stay focused on the shield or pause screen.")

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
