import Foundation

struct BadgeModel: Identifiable {
    let id = UUID()
    let cityName: String
    var totalPOI: Int
    var certifiedPOI: Int
    var unlockedDate: Date?
    var discoveredImageNames: [String] = []  // <-- Usa i nomi asset
    var cityStory: String

    var isUnlocked: Bool {
        certifiedPOI >= totalPOI
    }

    var progressText: String {
        "\(certifiedPOI)/\(totalPOI)"
    }

    var badgeImageName: String {
        let cityKey = cityName
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "'", with: "")
        return isUnlocked
            ? "badge_\(cityKey)_sbloccato"
            : "badge_\(cityKey)_bloccato"
    }
}
