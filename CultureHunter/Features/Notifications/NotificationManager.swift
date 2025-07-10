import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    // Richiedi il permesso per le notifiche (chiamare all'avvio dell'app)
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Errore richiesta permessi notifiche: \(error.localizedDescription)")
            }
            print("Permessi notifiche concessi? \(granted)")
        }
    }

    // Invia UNA SOLA notifica locale, opzionalmente con immagine e POI personalizzato
    func sendPOINearbyNotificationWithImage(for poi: MappedPOI? = nil) {
        let content = UNMutableNotificationContent()
        if let poi = poi {
            content.title = "Sei vicino a \(poi.title)"
            content.body = "Scatta una foto per scoprire di più su \(poi.title) e guadagnare crediti!"
        } else {
            content.title = "Nuovo punto di interesse nei dintorni!"
            content.body = "Apri l'app e scatta una foto per conoscerne le informazioni e guadagnare crediti"
        }
        content.sound = .default

        // Opzionale: allega immagine se presente negli assets (nome: "Notifications")
        if let image = UIImage(named: "Notifications"),
           let attachment = createImageAttachment(image: image, identifier: "poiImage") {
            content.attachments = [attachment]
        }

        // Usa sempre lo stesso identifier per non accumulare notifiche
        let identifier = poi?.id.uuidString ?? "poi_notification"

        // Rimuovi prima eventuali notifiche pendenti con lo stesso identifier
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Immediato
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore invio notifica: \(error.localizedDescription)")
            } else {
                print("Notifica inviata con successo!")
            }
        }
    }

    // Crea UNNotificationAttachment da un'immagine in memoria
    private func createImageAttachment(image: UIImage, identifier: String) -> UNNotificationAttachment? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(identifier)_\(UUID().uuidString).jpg")
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            try data.write(to: fileURL)
            let attachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
            return attachment
        } catch {
            print("Errore salvataggio o creazione attachment immagine notifica: \(error.localizedDescription)")
            return nil
        }
    }
}
