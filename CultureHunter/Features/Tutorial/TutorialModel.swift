//
//  TutorialPageType.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

enum TutorialPageType {
    case welcome
    case appInfo(AppInfoStep)
    case avatarCreation(AvatarCreationStep)
    case final
}


enum AppInfoStep: Int, CaseIterable {
    case map = 0
    case diary = 1
    case poi = 2
    case badges = 3
    case shop = 4
    case profile = 5
}


enum AvatarCreationStep: Int, CaseIterable {
    case style = 0
    case hair = 1
    case eyes = 2       
    case skin = 3
    case missionTime = 4
}

struct TutorialPage {
    let type: TutorialPageType
    let title: String
    let description: String
    let imageName: String?
    let bottomImages: [String]?
    
    static var missionTime: TutorialPage {
        TutorialPage(
            type: .avatarCreation(.missionTime),
            title: "Orario Missione",
            description: "Scegli quando ricevere la missione giornaliera",
            imageName: nil,
            bottomImages: nil
        )
    }
}

