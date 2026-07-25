import SwiftUI

struct PINEntryView: View {
    let title: String
    let onSubmit: (String) -> Bool
    let onCancel: () -> Void

    @State private var pin = ""
    @State private var errorMessage: String?
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
                        .onChange(of: pin) { _, _ in errorMessage = nil }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }

                    Button("Confirm") {
                        VANASIHaptics.light()
                        if onSubmit(pin) {
                            onCancel()
                        } else {
                            errorMessage = "Incorrect PIN."
                            VANASIHaptics.medium()
                        }
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
    @State private var selectedMode = EndLockProtectionStore.mode
    @State private var showRemovePIN = false
    @State private var pinSetupForSelection = false
    @State private var pin = ""
    @State private var confirm = ""
    @State private var error: String?
    @State private var isBusy = false

    var body: some View {
        ZStack {
            VANASIBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Choose how to confirm turning off monk mode.")
                        .font(.footnote.weight(.light))
                        .foregroundStyle(VANASITheme.textSecondary)
                        .lineSpacing(4)

                    ForEach(EndLockProtectionMode.allCases) { option in
                        modeRow(option)
                    }

                    if pinSetupForSelection {
                        pinSetupFields
                    }

                    if selectedMode != .none, EndLockProtectionStore.isRequired {
                        Button("Turn off protection") {
                            beginTurnOffProtection()
                        }
                        .buttonStyle(VANASITextButton())
                        .foregroundStyle(.orange)
                        .padding(.top, 8)
                    }

                    if let error {
                        Text(error).font(.footnote).foregroundStyle(.orange)
                    }
                }
                .padding(32)
            }
        }
        .navigationTitle("End lock security")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(VANASITheme.void, for: .navigationBar)
        .onAppear { selectedMode = EndLockProtectionStore.mode }
        .sheet(isPresented: $showRemovePIN) {
            PINEntryView(
                title: "Enter PIN to turn off protection",
                onSubmit: { entered in
                    if EndLockProtection.disableProtection(currentPIN: entered) {
                        selectedMode = .none
                        VANASIHaptics.success()
                        return true
                    }
                    return false
                },
                onCancel: { showRemovePIN = false }
            )
        }
    }

    private func modeRow(_ option: EndLockProtectionMode) -> some View {
        let isSelected = selectedMode == option && EndLockProtectionStore.mode == option
            || (option == .fourDigitPIN && pinSetupForSelection)
        return Button {
            selectMode(option)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? VANASITheme.textPrimary : VANASITheme.textWhisper)
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.subheadline)
                        .foregroundStyle(VANASITheme.textPrimary)
                    Text(option.subtitle)
                        .font(.caption)
                        .foregroundStyle(VANASITheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
    }

    private func selectMode(_ option: EndLockProtectionMode) {
        error = nil
        selectedMode = option

        switch option {
        case .none:
            if EndLockProtectionStore.isRequired {
                beginTurnOffProtection()
            } else {
                EndLockProtection.mode = .none
            }
        case .fourDigitPIN:
            if PINProtection.isEnabled {
                EndLockProtection.mode = .fourDigitPIN
                pinSetupForSelection = false
            } else {
                pinSetupForSelection = true
                clearPinFields()
            }
        case .faceID, .devicePasscode:
            pinSetupForSelection = false
            guard EndLockProtection.isAvailable(option) else {
                error = option == .faceID
                    ? "Face ID or Touch ID is not available."
                    : "Device passcode is not available."
                return
            }
            isBusy = true
            Task {
                let ok = await EndLockProtection.authenticate(for: option)
                await MainActor.run {
                    isBusy = false
                    if ok {
                        EndLockProtection.mode = option
                        VANASIHaptics.success()
                        selectedMode = option
                    } else {
                        error = "Authentication failed or was cancelled."
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var pinSetupFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create 4-digit PIN")
                .font(.caption)
                .foregroundStyle(VANASITheme.textWhisper)
            SecureField("New PIN", text: $pin)
                .keyboardType(.numberPad)
                .foregroundStyle(VANASITheme.textPrimary)
            SecureField("Confirm PIN", text: $confirm)
                .keyboardType(.numberPad)
                .foregroundStyle(VANASITheme.textPrimary)
            Button("Save PIN") { savePIN() }
                .buttonStyle(VANASISecondaryButton())
        }
        .padding(.top, 8)
    }

    private func savePIN() {
        guard pin == confirm else {
            error = "PINs do not match."
            return
        }
        if let msg = EndLockProtection.setMode(.fourDigitPIN, pin: pin) {
            error = msg
            return
        }
        VANASIHaptics.success()
        pinSetupForSelection = false
        selectedMode = .fourDigitPIN
        clearPinFields()
    }

    private func beginTurnOffProtection() {
        error = nil
        switch EndLockProtectionStore.mode {
        case .none:
            EndLockProtection.mode = .none
        case .fourDigitPIN:
            showRemovePIN = true
        case .faceID, .devicePasscode:
            isBusy = true
            Task {
                let ok = await EndLockProtection.authenticateSystem()
                await MainActor.run {
                    isBusy = false
                    if ok {
                        _ = EndLockProtection.disableProtection(currentPIN: nil)
                        selectedMode = .none
                        VANASIHaptics.success()
                    }
                }
            }
        }
    }

    private func clearPinFields() {
        pin = ""
        confirm = ""
    }
}
