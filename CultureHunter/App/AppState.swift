//
//  AppState.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

class AppState: ObservableObject {
    @AppStorage("hasCreatedAvatar") var hasCreatedAvatar = false
    @AppStorage("hasSeenTutorial") var hasSeenTutorial = false
    
    @Published var showingTutorial = false
    @Published var showingAvatarCreation = false
    
    func checkFirstLaunch() {
        if !hasCreatedAvatar {
            showingAvatarCreation = true
        }
    }
    
    func openTutorial() {
        showingTutorial = true
    }
}
