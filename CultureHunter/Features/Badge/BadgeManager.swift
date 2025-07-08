import Foundation

class BadgeManager: ObservableObject {
    @Published var badges: [BadgeModel] = []
    // Tiene traccia degli id dei POI già certificati per evitare doppi conteggi
    private var certifiedPOIIDs: Set<UUID> = []
    
    init() {
        badges = [
            BadgeModel(cityName: "Salerno", totalPOI: 10, certifiedPOI: 7, unlockedDate: nil),
            BadgeModel(cityName: "Cetara", totalPOI: 10, certifiedPOI: 2, unlockedDate: nil),
            BadgeModel(cityName: "Cava de' Tirreni", totalPOI: 15, certifiedPOI: 0, unlockedDate: nil),
        ]
    }
    
    /// Aggiorna il badge per una città ogni volta che un nuovo POI viene scoperto.
    /// - Parameters:
    ///   - city: Nome della città
    ///   - poiID: ID univoco del POI (per evitare doppioni)
    func updateBadgeForDiscoveredPOI(city: String, poiID: UUID) {
        // Se già conteggiato, non fare nulla
        guard !certifiedPOIIDs.contains(poiID) else { return }
        certifiedPOIIDs.insert(poiID)
        guard let index = badges.firstIndex(where: { $0.cityName == city }) else { return }
        badges[index].certifiedPOI += 1
        if badges[index].certifiedPOI >= badges[index].totalPOI, badges[index].unlockedDate == nil {
            badges[index].unlockedDate = Date()
        }
        objectWillChange.send()
    }
    
    func reset() {
        for i in badges.indices {
            badges[i].certifiedPOI = 0
            badges[i].unlockedDate = nil
        }
        certifiedPOIIDs.removeAll()
        objectWillChange.send()
    }
}
