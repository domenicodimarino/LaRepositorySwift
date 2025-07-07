//
//  CultureHunterApp.swift
//  CultureHunterApp
//
//  Created by Domenico Di Marino on 20/06/25.
//

import SwiftUI
import UserNotifications

// Delegate per mostrare notifiche anche con app in foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Mostra la notifica anche se l'app è aperta
        completionHandler([.banner, .sound, .list])
    }
}

@main
struct CultureHunterApp: App {
    init() {
        // Imposta il delegate all’avvio dell’app
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
