//
//  CultureHunterApp.swift
//  CultureHunterApp
//
//  Created by Domenico Di Marino on 20/06/25.
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}

@main
struct CultureHunterApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var avatarViewModel = AvatarViewModel()
    
    let persistenceController = PersistenceController.shared
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView(avatarViewModel: avatarViewModel)
                .environmentObject(appState)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    appState.checkFirstLaunch()
                    
                }
                .sheet(isPresented: $appState.showingTutorial) {
                    MasterTutorialView(
                        isPresented: $appState.showingTutorial,
                        avatarViewModel: avatarViewModel,
                        skipAvatarCreation: true
                    )
                }
                .fullScreenCover(isPresented: $appState.showingAvatarCreation) {
                    MasterTutorialView(
                        isPresented: $appState.showingAvatarCreation,
                        avatarViewModel: avatarViewModel,
                        skipAvatarCreation: false
                    )
                }
        }
    }
}
