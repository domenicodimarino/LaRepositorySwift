//
//  NotificationManager.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func sendPOINearbyNotificationWithImage() {
        let content = UNMutableNotificationContent()
        content.title = "Nuovo punto di interesse nei dintorni!"
        content.body = "Apri l'app e scatta una foto per conoscerne le informazioni e guadagnare crediti"
        content.sound = .default

        // Prendi l'immagine dall'assets (NON AppIcon) – esempio: "poi_notification"
        if let image = UIImage(named: "AppIcon"),
           let attachment = createImageAttachment(image: image, identifier: "poiImage") {
            content.attachments = [attachment]
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func createImageAttachment(image: UIImage, identifier: String) -> UNNotificationAttachment? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(identifier).jpg")
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            try data.write(to: fileURL)
            return try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
        } catch {
            print("Errore salvataggio immagine notifica: \(error)")
            return nil
        }
    }
}
