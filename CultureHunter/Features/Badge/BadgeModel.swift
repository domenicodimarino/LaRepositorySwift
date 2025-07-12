import Foundation

struct BadgeModel: Identifiable {
    let id = UUID()
    let cityName: String
    var totalPOI: Int // <-- ora variabile!
    var certifiedPOI: Int
    var unlockedDate: Date?   // nil se non ancora sbloccato

    var isUnlocked: Bool {
        certifiedPOI >= totalPOI
    }

    var progressText: String {
        "\(certifiedPOI)/\(totalPOI)"
    }

    // Nome asset badge in Assets.xcassets
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
