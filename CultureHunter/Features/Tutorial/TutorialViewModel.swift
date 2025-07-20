//
//  TutorialViewModel.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI
import Combine

class TutorialViewModel: ObservableObject {
    // Stato globale del tutorial
    @Published var currentSection: TutorialSection = .welcome
    @Published var appInfoStep: AppInfoStep = .map
    @Published var avatarCreationStep: AvatarCreationStep = .style
    
    // Avatar ViewModel per la creazione
    @Published var avatarViewModel = AvatarViewModel()
    
    // Mission time properties
        @Published var missionHour: Int = UserDefaults.standard.integer(forKey: "missionTimeHourKey")
        @Published var missionMinute: Int = UserDefaults.standard.integer(forKey: "missionTimeMinuteKey")
    
    private let skipAvatarCreation: Bool
    
        init(avatarViewModel: AvatarViewModel, skipAvatarCreation: Bool = false) {
            self.avatarViewModel = avatarViewModel
            self.skipAvatarCreation = skipAvatarCreation
            self.currentSection = .welcome
            self.appInfoStep = .map
            self.avatarCreationStep = .style
        }
    // Flag per tracciare lo stato
    @AppStorage("hasSeenTutorial") var hasSeenTutorial = false
    @AppStorage("hasCreatedAvatar") var hasCreatedAvatar = false
    
    // Metodi di navigazione
    func nextAppInfoStep() {
            if let next = AppInfoStep(rawValue: appInfoStep.rawValue + 1) {
                appInfoStep = next
            } else {
                // Usa il nuovo flag qui!
                if skipAvatarCreation {
                    currentSection = .final
                } else {
                    currentSection = .avatarCreation
                }
            }
        }
    
    func prevAppInfoStep() {
        if let prev = AppInfoStep(rawValue: appInfoStep.rawValue - 1) {
            appInfoStep = prev
        } else {
            // Torniamo alla schermata di benvenuto
            currentSection = .welcome
        }
    }
    
    func nextAvatarStep() {
        if let next = AvatarCreationStep(rawValue: avatarCreationStep.rawValue + 1) {
            avatarCreationStep = next
        } else {
            // Abbiamo finito la creazione avatar, passiamo alla schermata finale
            currentSection = .final
        }
    }
    
    func prevAvatarStep() {
        if let prev = AvatarCreationStep(rawValue: avatarCreationStep.rawValue - 1) {
            avatarCreationStep = prev
        } else {
            // Torniamo all'ultima schermata info
            currentSection = .appInfo
            appInfoStep = AppInfoStep.allCases.last!
        }
    }
    
    func completeTutorial() {
        
        hasSeenTutorial = true
        hasCreatedAvatar = true
        // Save mission time
                UserDefaults.standard.set(missionHour, forKey: "missionTimeHourKey")
                UserDefaults.standard.set(missionMinute, forKey: "missionTimeMinuteKey")
        avatarViewModel.save()
    }
    
    // Stati del tutorial
    enum TutorialSection {
        case welcome        // Schermata benvenuto
        case appInfo        // Info sull'app
        case avatarCreation // Creazione avatar
        case final         // Schermata finale
    }
}
