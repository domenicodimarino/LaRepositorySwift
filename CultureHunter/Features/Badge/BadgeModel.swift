import Foundation

struct BadgeModel: Identifiable, Codable { // <--- AGGIUNGI Codable QUI
    let id: UUID
    let cityName: String
    var totalPOI: Int
    var certifiedPOI: Int
    var unlockedDate: Date?
    var discoveredImageNames: [String] = []
    var cityStory: String

    // MARK: - Init custom per id opzionale
    init(id: UUID = UUID(), cityName: String, totalPOI: Int, certifiedPOI: Int, unlockedDate: Date?, discoveredImageNames: [String] = [], cityStory: String) {
        self.id = id
        self.cityName = cityName
        self.totalPOI = totalPOI
        self.certifiedPOI = certifiedPOI
        self.unlockedDate = unlockedDate
        self.discoveredImageNames = discoveredImageNames
        self.cityStory = cityStory
    }

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
