import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationManager: ObservableObject {
    @Published var lastNotificationSent: Date? = nil
    private let notificationQueue = DispatchQueue(label: "notification.queue")
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Errore richiesta permessi notifiche: \(error.localizedDescription)")
            }
            print("Permessi notifiche concessi? \(granted)")
        }
    }

    /// Invia notifica solo se il POI non è scoperto, oppure non invia la notifica generica se non vuoi
    func sendPOINearbyNotificationWithImage(for poi: MappedPOI? = nil, allowGeneric: Bool = false) {
        // Notifica specifica per POI non scoperto
        if let poi = poi {
            if poi.isDiscovered {
                print("POI già scoperto, nessuna notifica inviata.")
                return
            }
        } else if !allowGeneric {
            print("Nessun POI specifico, nessuna notifica generica inviata.")
            return
        }
        
        let content = UNMutableNotificationContent()
        if let poi = poi {
            content.title = "Sei vicino a \(poi.title)"
            content.body = "Scatta una foto per scoprire di più su \(poi.title) e guadagnare crediti!"
        } else {
            content.title = "Nuovo punto di interesse nei dintorni!"
            content.body = "Apri l'app e scatta una foto per conoscerne le informazioni e guadagnare crediti"
        }
        content.sound = .default

        if let image = UIImage(named: "Notifications"),
           let attachment = self.createImageAttachment(image: image, identifier: "poiImage") {
            content.attachments = [attachment]
        }

        let identifier = poi?.id.uuidString ?? "poi_notification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Errore invio notifica: \(error.localizedDescription)")
            } else {
                print("Notifica inviata con successo!")
                DispatchQueue.main.async {
                    self?.lastNotificationSent = Date()
                }
            }
        }
    }
    
    func sendMissionNotification(description: String, reward: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Nuova missione disponibile!"
        content.body = "💰 \(description) - Ricompensa: \(reward) monete"
        content.sound = .default
        
        let identifier = "mission_notification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.lastNotificationSent = Date()
                }
            }
        }
    }

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
    
    func cancelMissionNotifications() {
        DispatchQueue.main.async {
            let identifier = "mission_notification"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }
}
