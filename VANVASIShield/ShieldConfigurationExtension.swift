import ManagedSettings
import ManagedSettingsUI
import UIKit

class VANVASIShieldConfigurationProvider: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        shieldConfig(
            title: "Paused by VANVASI",
            subtitle: "Take a breath · \(VANVASIConfig.singleAppMinutes) min unlock"
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        shieldConfig(
            title: "Web paused",
            subtitle: "Open VANVASI to unlock · \(VANVASIConfig.unlockAllMinutes) min"
        )
    }

    private func shieldConfig(title: String, subtitle: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1),
            icon: UIImage(systemName: "leaf"),
            title: ShieldConfiguration.Label(text: title, color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Unlock with intention", color: .black),
            primaryButtonBackgroundColor: UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Stay focused", color: .lightGray)
        )
    }
}
