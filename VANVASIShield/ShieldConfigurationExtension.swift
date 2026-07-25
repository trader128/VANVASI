import ManagedSettings
import ManagedSettingsUI
import UIKit

class VANVASIShieldConfigurationProvider: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        shieldConfig(subtitle: "\(VANVASIConfig.singleAppMinutes) min unlock")
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        shieldConfig(subtitle: "Open VANVASI")
    }

    private func shieldConfig(subtitle: String) -> ShieldConfiguration {
        let icon = UIImage(systemName: "lock.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 28, weight: .light))
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: .black,
            icon: icon,
            title: ShieldConfiguration.Label(text: "Pause.", color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: UIColor(white: 1, alpha: 0.4)),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Unlock", color: .black),
            primaryButtonBackgroundColor: UIColor(white: 1, alpha: 0.92),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Stay", color: UIColor(white: 1, alpha: 0.4))
        )
    }
}
