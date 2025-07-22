//
//  GroqAPI.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 22/07/25.
//

import Foundation

// Helper per chiamare Groq e ottenere la storia
func fetchHistoryForPOI(poi: MappedPOI, completion: @escaping (String?) -> Void) {
    let systemPrompt = "Sei una guida turistica italiana. Scrivi una breve storia coinvolgente e ben scritta per questo luogo, senza inventare dati non forniti."
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
