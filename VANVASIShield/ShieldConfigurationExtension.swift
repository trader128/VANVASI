import ManagedSettings
import ManagedSettingsUI
import UIKit

class VANVASIShieldConfigurationProvider: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        shieldConfig(
            subtitle: "Monk mode · up to \(VANVASIConfig.singleAppMinutes) min in VANVASI"
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        shieldConfig(
            subtitle: "Monk mode · open VANVASI to continue"
        )
    }

    private func shieldConfig(subtitle: String) -> ShieldConfiguration {
        let gold = UIColor(red: 0.83, green: 0.69, blue: 0.22, alpha: 1)
        let icon = UIImage(systemName: "hand.raised.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 30, weight: .light))
            .withTintColor(gold, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.04, green: 0.04, blue: 0.03, alpha: 1),
            icon: icon,
            title: ShieldConfiguration.Label(text: "Pause.", color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: UIColor(white: 1, alpha: 0.45)),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Open VANVASI", color: .black),
            primaryButtonBackgroundColor: UIColor(white: 1, alpha: 0.94),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Stay focused", color: UIColor(white: 1, alpha: 0.55))
        )
    }
}
