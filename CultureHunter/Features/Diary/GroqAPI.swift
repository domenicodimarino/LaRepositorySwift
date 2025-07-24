//
//  GroqAPI.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 22/07/25.
//

import Foundation

func fetchHistoryForPOI(poi: MappedPOI, completion: @escaping (String?) -> Void) {
    fetchBestWikipediaPageName(for: poi) { bestWikiName in
        
        if let nameToUse = bestWikiName,
           isAcceptableWikiPage(for: poi, wikiTitle: nameToUse) {
            fetchWikipediaHistorySection(for: nameToUse) { wikiHistory in
                if let wikiHistory = wikiHistory, !wikiHistory.isEmpty {
                    print("Prendo da wikipedia: \(nameToUse)")
                    let systemPrompt = "Riformula il seguente testo storico in modo scorrevole e interessante, senza aggiungere informazioni che non siano già presenti nel testo. Non parlare della città, ma parla solo del punto di interesse in questione"
                    let userPrompt = """
                    Luogo: \(poi.diaryPlaceName)
                    Testo storico: \(wikiHistory)
                    """
                    let messagesPayload = [
                        ["role": "system", "content": systemPrompt],
                        ["role": "user", "content": userPrompt]
                    ]
                    groqChat(messagesPayload: messagesPayload, completion: completion)
                    return
                }
            }
        }
        // Se non accettabile (pagina generica o non trovata), usa subito Groq!
        print("Prendo non da wikipedia")
        let systemPrompt = "Scrivi una breve storia sull'origine di questo luogo e sull'utilizzo che ne è stato fatto nel tempo, fino ai giorni nostri, senza aggiungere informazioni non fornite né fare riferimento alla città in cui si trova."
        let userPrompt = """
        Luogo: \(poi.diaryPlaceName)
        Città: \(poi.city)
        Provincia: \(poi.province)
        Anno di costruzione: \(poi.yearBuilt ?? "dato non disponibile")
        Indirizzo: \(poi.address)
        """
        let messagesPayload = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        groqChat(messagesPayload: messagesPayload, completion: completion)
    }
}

// Controlla che il titolo wikipedia trovato sia accettabile come POI e NON solo città/provincia
private func isAcceptableWikiPage(for poi: MappedPOI, wikiTitle: String) -> Bool {
    let normalizedTitle = wikiTitle.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedPOI = poi.diaryPlaceName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedCity = poi.city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedProvince = poi.province.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    // Non accettare la città o la provincia come titolo
    if normalizedTitle == normalizedCity || normalizedTitle == normalizedProvince {
        return false
    }
    // Accetta solo se il titolo contiene il nome del POI
    return normalizedTitle.contains(normalizedPOI)
}

// --------- NUOVA LOGICA Wikipedia ---------

// Prova a trovare il titolo Wikipedia più specifico e corretto
private func fetchBestWikipediaPageName(for poi: MappedPOI, completion: @escaping (String?) -> Void) {
    let candidates = [
        "\(poi.diaryPlaceName) (\(poi.city))",
        "\(poi.diaryPlaceName) (\(poi.province))",
        "\(poi.diaryPlaceName) \(poi.city)",
        poi.diaryPlaceName
    ]
    tryWikipediaPagesSequentially(candidates: candidates, poi: poi, completion: completion)
}

// Prova ogni candidato finché non trova una pagina valida (non di disambiguazione)
private func tryWikipediaPagesSequentially(candidates: [String], poi: MappedPOI, completion: @escaping (String?) -> Void) {
    var remaining = candidates
    func tryNext() {
        guard let name = remaining.first else {
            // Fallback: ricerca fuzzy Wikipedia API
            searchWikipedia(for: poi) { fuzzyTitle in
                completion(fuzzyTitle)
            }
            return
        }
        fetchWikipediaSummary(for: name) { summary in
            if let summary = summary,
               !summary.lowercased().contains("disambiguazione") &&
               !summary.lowercased().contains("puoi") &&
               !summary.isEmpty {
                completion(name)
            } else {
                remaining.removeFirst()
                tryNext()
            }
        }
    }
    tryNext()
}

// Ricerca Wikipedia API: trova la voce migliore col nome + città
private func searchWikipedia(for poi: MappedPOI, completion: @escaping (String?) -> Void) {
    let query = "\(poi.diaryPlaceName) \(poi.city)"
    let urlStr = "https://it.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&format=json"
    guard let url = URL(string: urlStr) else { completion(nil); return }
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query = json["query"] as? [String: Any],
              let searchResults = query["search"] as? [[String: Any]],
              let firstResult = searchResults.first,
              let title = firstResult["title"] as? String else {
            completion(nil)
            return
        }
        completion(title)
    }.resume()
}

// --------- FUNZIONI ORIGINALI ---------

// Estrai riassunto Wikipedia REST API
private func fetchWikipediaSummary(for placeName: String, completion: @escaping (String?) -> Void) {
    let encodedName = placeName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? placeName
    let urlStr = "https://it.wikipedia.org/api/rest_v1/page/summary/\(encodedName)"
    guard let url = URL(string: urlStr) else { completion(nil); return }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let extract = json["extract"] as? String else {
            completion(nil)
            return
        }
        completion(extract)
    }.resume()
}

// Estrai sezione "Storia" o fallback su summary
private func fetchWikipediaHistorySection(for placeName: String, completion: @escaping (String?) -> Void) {
    let encodedName = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? placeName
    let urlStr = "https://it.wikipedia.org/w/api.php?action=parse&page=\(encodedName)&prop=sections&format=json"
    guard let url = URL(string: urlStr) else { completion(nil); return }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let parse = json["parse"] as? [String: Any],
              let sections = parse["sections"] as? [[String: Any]] else {
            completion(nil)
            return
        }
        if let storiaSection = sections.first(where: { ($0["line"] as? String)?.lowercased().contains("storia") == true }),
           let sectionIndex = storiaSection["index"] as? String {
            let sectionUrl = "https://it.wikipedia.org/w/api.php?action=parse&page=\(encodedName)&section=\(sectionIndex)&prop=text&format=json"
            guard let url2 = URL(string: sectionUrl) else { completion(nil); return }
            URLSession.shared.dataTask(with: url2) { data2, _, error2 in
                guard let data2 = data2,
                      let json2 = try? JSONSerialization.jsonObject(with: data2) as? [String: Any],
                      let parse2 = json2["parse"] as? [String: Any],
                      let textDict = parse2["text"] as? [String: Any],
                      let html = textDict["*"] as? String else {
                    completion(nil)
                    return
                }
                let plainText = html.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
                completion(plainText)
            }.resume()
        } else {
            fetchWikipediaSummary(for: placeName, completion: completion)
        }
    }.resume()
}

// Funzione Groq come in originale
private func groqChat(messagesPayload: [[String: String]], completion: @escaping (String?) -> Void) {
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
