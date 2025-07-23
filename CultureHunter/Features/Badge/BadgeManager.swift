import Foundation

class BadgeManager: ObservableObject {
    @Published var badges: [BadgeModel] = [] {
        didSet { saveBadgesProgress() }
    }
    private var certifiedPOIIDs: Set<UUID> = []
    private let badgesKey = "badges_progress"
    
    func saveBadgesProgress() {
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: badgesKey)
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let saved = try? JSONDecoder().decode([BadgeModel].self, from: data) {
            badges = saved.map { badge in
                var b = badge
                b.cityStory = badge.cityStory
                // PATCH: imposta la data se il badge è già sbloccato!
                if b.certifiedPOI >= b.totalPOI && b.unlockedDate == nil {
                    b.unlockedDate = Date()
                }
                return b
            }
        } else {
            badges = [
                BadgeModel(cityName: "Salerno", totalPOI: 16, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: ["castello_arechi","chiesa_monte_morti","chiesa_sangiorgio","chiesa_ssannunziata","duomo_salerno","giardino_minerva","museo_archeologico","museo_diocesano_salerno","museo_sbarco","museo_virtuale","piazza_liberta","porto_salerno","saragnano","stadio_arechi","teatro_verdi","velia"], cityStory: ""),
                BadgeModel(cityName: "Cetara", totalPOI: 5, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: ["chiesa_sanpietro","costantinopoli","fabbrica_nettuno","piazza_sanfra","torre_di_cetara"], cityStory: ""),
                BadgeModel(cityName: "Cava de' Tirreni", totalPOI: 11, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: ["caduti", "abbazia","chiesa_avvocatella","chiesa_sanlo","duomo_cava","giardini_sangio","madonna_olmo","purgatorio","santuario","villa_comunale","chiesa_sanrocco"], cityStory: ""),
            ]
            // PATCH: imposta la data per tutti i badge già sbloccati
            for i in badges.indices {
                if badges[i].certifiedPOI >= badges[i].totalPOI && badges[i].unlockedDate == nil {
                    badges[i].unlockedDate = Date()
                }
            }
        }
    }

    func addPOI(for city: String, imageName: String?) {
        if let index = badges.firstIndex(where: { $0.cityName == city }) {
            badges[index].totalPOI += 1
            if let imgName = imageName {
                badges[index].discoveredImageNames.append(imgName)
            }
        } else {
            badges.append(BadgeModel(
                cityName: city,
                totalPOI: 1,
                certifiedPOI: 0,
                unlockedDate: nil,
                discoveredImageNames: imageName != nil ? [imageName!] : [],
                cityStory: ""
            ))
        }
    }

    func updateBadgeForDiscoveredPOI(city: String, poiID: UUID, imageName: String?, mappedPOIs: [MappedPOI]) {
        guard !certifiedPOIIDs.contains(poiID) else { return }
        certifiedPOIIDs.insert(poiID)
        guard let index = badges.firstIndex(where: { $0.cityName == city }) else { return }
        badges[index].certifiedPOI += 1
        if let imgName = imageName {
            badges[index].discoveredImageNames.append(imgName)
        }
        if badges[index].certifiedPOI >= badges[index].totalPOI, badges[index].unlockedDate == nil {
            badges[index].unlockedDate = Date()
            // Genera la storia della città con Groq
            generateCityStoryWithGroq(cityName: city, mappedPOIs: mappedPOIs) { [weak self] storia in
                DispatchQueue.main.async {
                    if let storia = storia {
                        self?.badges[index].cityStory = storia
                        self?.saveBadgesProgress()
                    }
                }
            }
        }
    }

    func reset() {
        for i in badges.indices {
            badges[i].certifiedPOI = 0
            badges[i].unlockedDate = nil
            badges[i].discoveredImageNames = []
            badges[i].cityStory = ""
        }
        certifiedPOIIDs.removeAll()
        saveBadgesProgress()
    }

    // Funzione per chiamare Groq e generare la storia della città
    private func generateCityStoryWithGroq(cityName: String, mappedPOIs: [MappedPOI], completion: @escaping (String?) -> Void) {
        let poiNames = mappedPOIs.filter { $0.city == cityName }.map { $0.diaryPlaceName }
        let systemPrompt = """
        Racconta una storia coinvolgente di come è nata la città di \(cityName) e come la troviamo ad oggi. 
        """
        let userPrompt = ""
        let messagesPayload = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else { completion(nil); return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "llama3-70b-8192",
            "messages": messagesPayload,
            "temperature": 0.7
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { completion(nil); return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion(nil)
                return
            }
            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
}

extension BadgeManager {
    /// Carica la storia della città, se non presente la genera con Groq
    func fetchCityStoryIfNeeded(for city: String, mappedPOIs: [MappedPOI], completion: @escaping (String?) -> Void) {
        // Cerca il badge corrispondente
        if let badge = badges.first(where: { $0.cityName == city }), !badge.cityStory.isEmpty {
            completion(badge.cityStory)
        } else if let idx = badges.firstIndex(where: { $0.cityName == city }) {
            // Genera la storia con Groq
            generateCityStoryWithGroq(cityName: city, mappedPOIs: mappedPOIs) { [weak self] storia in
                DispatchQueue.main.async {
                    if let storia = storia {
                        self?.badges[idx].cityStory = storia
                        self?.saveBadgesProgress()
                    }
                    completion(storia)
                }
            }
        } else {
            completion(nil)
        }
    }
}
