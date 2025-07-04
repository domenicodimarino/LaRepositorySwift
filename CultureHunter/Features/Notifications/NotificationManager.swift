//
//  NotificationManager.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func sendPOINearbyNotification(poiName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Sei vicino a \(poiName)!"
        content.body = "Aggiungilo al tuo diario scattando una foto!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // send immediately
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
