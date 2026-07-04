import SwiftUI

struct PINEntryView: View {
    let title: String
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    @State private var pin = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                VANASIBackground()
                VStack(spacing: 32) {
                    Text(title)
                        .font(.subheadline.weight(.light))
                        .foregroundStyle(VANASITheme.textSecondary)

                    SecureField("••••", text: $pin)
                        .keyboardType(.numberPad)
                        .focused($focused)
                        .multilineTextAlignment(.center)
                        .font(.title.weight(.ultraLight).monospacedDigit())
                        .foregroundStyle(VANASITheme.textPrimary)
                        .padding(.vertical, 16)
                        .background(VANASITheme.ringFill)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, 48)

                    Button("Confirm") {
                        VANASIHaptics.light()
                        onSubmit(pin)
                    }
                    .buttonStyle(VANASIPrimaryButton())
                    .padding(.horizontal, 32)
                    .disabled(pin.count < 4)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(VANASITheme.textSecondary)
                }
            }
            .toolbarBackground(VANASITheme.void, for: .navigationBar)
            .onAppear { focused = true }
        }
        .preferredColorScheme(.dark)
    }
}

struct PINSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pin = ""
    @State private var confirm = ""
    @State private var error: String?

    var body: some View {
        ZStack {
            VANASIBackground()
            VStack(alignment: .leading, spacing: 24) {
                Text("PIN to disable lock")
                    .font(.subheadline.weight(.light))
                    .foregroundStyle(VANASITheme.textSecondary)

                SecureField("New PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .foregroundStyle(VANASITheme.textPrimary)
                SecureField("Confirm", text: $confirm)
                    .keyboardType(.numberPad)
                    .foregroundStyle(VANASITheme.textPrimary)

                if let error {
                    Text(error).font(.footnote).foregroundStyle(.orange)
                }

                Button("Save") { save() }
                    .buttonStyle(VANASIPrimaryButton())
            }
            .padding(32)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
    }

    private func save() {
        guard pin == confirm else {
            error = "PINs do not match."
            return
        }
        guard PINProtection.setPIN(pin) else {
            error = "Use at least 4 digits."
            return
        }
        VANASIHaptics.success()
        dismiss()
    }
}
