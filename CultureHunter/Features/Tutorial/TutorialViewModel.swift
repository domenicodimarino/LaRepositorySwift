//
//  TutorialViewModel.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI
import Combine

class TutorialViewModel: ObservableObject {
    @Published var currentSection: TutorialSection = .welcome
    @Published var appInfoStep: AppInfoStep = .map
    @Published var avatarCreationStep: AvatarCreationStep = .style
    
    @Published var avatarViewModel = AvatarViewModel()
    
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
    @AppStorage("hasSeenTutorial") var hasSeenTutorial = false
    @AppStorage("hasCreatedAvatar") var hasCreatedAvatar = false
    
    func nextAppInfoStep() {
            if let next = AppInfoStep(rawValue: appInfoStep.rawValue + 1) {
                appInfoStep = next
            } else {
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
            currentSection = .welcome
        }
    }
    
    func nextAvatarStep() {
        if let next = AvatarCreationStep(rawValue: avatarCreationStep.rawValue + 1) {
            avatarCreationStep = next
        } else {
            currentSection = .final
        }
    }
    
    func prevAvatarStep() {
        if let prev = AvatarCreationStep(rawValue: avatarCreationStep.rawValue - 1) {
            avatarCreationStep = prev
        } else {
            currentSection = .appInfo
            appInfoStep = AppInfoStep.allCases.last!
        }
    }
    
    func completeTutorial() {
        
        hasSeenTutorial = true
        hasCreatedAvatar = true
                UserDefaults.standard.set(missionHour, forKey: "missionTimeHourKey")
                UserDefaults.standard.set(missionMinute, forKey: "missionTimeMinuteKey")
        avatarViewModel.save()
    }
    
    enum TutorialSection {
        case welcome
        case appInfo
        case avatarCreation
        case final         
    }
}
