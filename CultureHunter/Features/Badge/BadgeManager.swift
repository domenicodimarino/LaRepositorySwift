import Foundation

class BadgeManager: ObservableObject {
    @Published var badges: [BadgeModel] = []
    // Tiene traccia degli id dei POI già certificati per evitare doppi conteggi
    private var certifiedPOIIDs: Set<UUID> = []

    init() {
        badges = [
            BadgeModel(cityName: "Salerno", totalPOI: 15, certifiedPOI: 0, unlockedDate: nil),
            BadgeModel(cityName: "Cetara", totalPOI: 5, certifiedPOI: 0, unlockedDate: nil),
            BadgeModel(cityName: "Cava de' Tirreni", totalPOI: 11, certifiedPOI: 0, unlockedDate: nil),
        ]
    }
    
    /// Aggiunge un nuovo POI alla città specificata, incrementando il totale dei POI
    func addPOI(for city: String) {
        if let index = badges.firstIndex(where: { $0.cityName == city }) {
            badges[index].totalPOI += 1
            objectWillChange.send()
        } else {
            // Se la città non esiste ancora, la crea con 1 POI
            badges.append(BadgeModel(cityName: city, totalPOI: 1, certifiedPOI: 0, unlockedDate: nil))
            objectWillChange.send()
        }
    }

    /// Aggiorna il badge per una città ogni volta che un nuovo POI viene scoperto.
    /// - Parameters:
    ///   - city: Nome della città
    ///   - poiID: ID univoco del POI (per evitare doppioni)
    func updateBadgeForDiscoveredPOI(city: String, poiID: UUID) {
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
