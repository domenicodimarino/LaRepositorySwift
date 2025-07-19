//
//  TutorialPageType.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

// Tipi di pagine del tutorial
enum TutorialPageType {
    case welcome                 // Prima pagina di benvenuto
    case appInfo(AppInfoStep)    // Pagine informative sull'app
    case avatarCreation(AvatarCreationStep) // Pagine di creazione avatar
    case final                   // Pagina finale
}

// Passi informativi dell'app
enum AppInfoStep: Int, CaseIterable {
    case map = 0        // Mappa
    case diary = 1      // Diario
    case poi = 2        // Punto di interesse
    case badges = 3     // Badge
    case shop = 4       // Shop
    case profile = 5    // Profilo
}

// Passi della creazione avatar
enum AvatarCreationStep: Int, CaseIterable {
    case style = 0      // Scelta maschio/femmina (StyleView)
    case hair = 1       // Scelta capelli (HairSelectionView)
    case eyes = 2       // Colore occhi (EyeColorView)
    case skin = 3       // Carnagione (CarnagioneView)
}

// Rappresenta una pagina del tutorial
struct TutorialPage {
    let type: TutorialPageType
    let title: String
    let description: String
    let imageName: String?
    let bottomImages: [String]?
}