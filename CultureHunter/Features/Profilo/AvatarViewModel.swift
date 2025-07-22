//
//  AvatarViewModel.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//

import Foundation

class AvatarViewModel: ObservableObject {
    @Published var avatar: AvatarData {
        didSet {
            save()
        }
    }

    init(avatar: AvatarData) {
        self.avatar = avatar
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "avatar_data"),
           let loaded = try? JSONDecoder().decode(AvatarData.self, from: data) {
            self.avatar = loaded
        } else {
            self.avatar = AvatarViewModel.defaultAvatar()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(avatar) {
            UserDefaults.standard.set(encoded, forKey: "avatar_data")
        }
    }
    
    func setName(_ name: String) {
        avatar.name = name
    }

    
    func setHair(_ hair: String) {
        avatar.hair = hair
    }
    
    func setSkin(_ skin: String) {
        let genderPrefix = avatar.gender == .male ? "male_" : "female_"
        
        let bodyBaseName = "010 body Body_color"
        avatar.skin = "\(bodyBaseName) \(skin)"
        
        let currentHead = avatar.head
        
        let headTypeComponents = currentHead.components(separatedBy: " ")
        if headTypeComponents.count >= 3 {
            let headType = headTypeComponents[2]
            avatar.head = "100 head \(headType) \(skin)"
        }
    }
    
    func setShirt(_ shirt: String) {
        avatar.shirt = shirt
    }
    
    func setPants(_ pants: String) {
        avatar.pants = pants
    }
    
    func setShoes(_ shoes: String) {
        avatar.shoes = shoes
    }
    
    func setEyes(_ eyes: String) {
        
        let genderPrefix = avatar.gender == .male ? "male_" : "female_"
        
        let eyeBaseName = "105 eye_color Eye_Color"
        avatar.eyes = "\(eyeBaseName) \(eyes)"
        
    }
    
    func setGender(_ gender: Gender) {
        avatar.gender = gender
    }
    
    func resetAvatar() {
        avatar = AvatarViewModel.defaultAvatar()
    }
    
    func loadAvatar(_ newAvatar: AvatarData) {
        avatar = newAvatar
    }
    
    func addCoins(_ amount: Int) {
        avatar.coins += amount
    }

    func spendCoins(_ amount: Int) -> Bool {
        if avatar.coins >= amount {
            avatar.coins -= amount
            return true
        }
        return false
    }

    func getCoins() -> Int {
        return avatar.coins
    }

    static func defaultAvatar() -> AvatarData {
        return AvatarData(
            name: "Visitatore",
            gender: .male,
            head: "100 head Human_male light",
            hair: "120 hair Plain black",
            skin: "010 body Body_color light",
            shirt: "035 clothes TShirt white",
            pants: "020 legs Pants black",
            shoes: "015 shoes Basic_Shoes black",
            eyes: "105 eye_color Eye_Color blue",
            coins: 40
        )
    }
}
