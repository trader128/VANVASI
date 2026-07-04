import Foundation
import SwiftData
import CryptoKit

enum PINProtection {
    private static let service = "com.vanasi.pin"
    private static let account = "user-pin"

    static func setPIN(_ pin: String) -> Bool {
        guard pin.count >= 4, pin.allSatisfy(\.isNumber) else { return false }
        let hash = sha256(pin)
        KeychainHelper.save(key: account, service: service, data: Data(hash.utf8))
        SharedStore.pinEnabled = true
        return true
    }

    static func verify(pin: String) -> Bool {
        guard let stored = KeychainHelper.load(key: account, service: service),
              let storedHash = String(data: stored, encoding: .utf8) else { return false }
        return storedHash == sha256(pin)
    }

    static func removePIN(currentPIN: String) -> Bool {
        guard verify(pin: currentPIN) else { return false }
        KeychainHelper.delete(key: account, service: service)
        SharedStore.pinEnabled = false
        return true
    }

    static var isEnabled: Bool { SharedStore.pinEnabled }

    private static func sha256(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

enum KeychainHelper {
    static func save(key: String, service: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String, service: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    static func delete(key: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
