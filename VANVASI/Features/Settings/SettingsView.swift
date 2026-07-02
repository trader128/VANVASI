import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var lockManager: MonkLockManager
    @State private var confirmEndLock = false

    var body: some View {
        NavigationStack {
            ZStack {
                VANASITheme.void.ignoresSafeArea()
                List {
                    Section {
                        Button(role: .destructive) { confirmEndLock = true } label: {
                            Text("End VANVASI Lock")
                        }
                    }

                    Section("Unlock") {
                        Label("One app — \(VANVASIConfig.singleAppMinutes) min", systemImage: "app")
                        Label("Full access — \(VANVASIConfig.unlockAllMinutes) min", systemImage: "lock.open")
                    }

                    Section("About") {
                        Text("VANVASI uses Apple's Screen Time API — the same technology as Opal and One Sec. All data stays on your device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("End VANVASI Lock?", isPresented: $confirmEndLock) {
                Button("End lock", role: .destructive) {
                    lockManager.disableLock()
                    context.insert(LockEvent(action: "emergency_exit"))
                    try? context.save()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
    }
}
