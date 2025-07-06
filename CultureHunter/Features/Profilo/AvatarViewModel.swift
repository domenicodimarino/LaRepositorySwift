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
    
    // Costruttore per Preview
    init(avatar: AvatarData) {
        self.avatar = avatar
    }
    
    // MARK: - Init e salvataggio
    
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
    
    // MARK: - Aggiornamento dei vari layer
    
    func setHair(_ hair: String) {
        avatar.hair = hair
    }
    
    func setSkin(_ skin: String) {
        // Mantieni il formato esistente dell'asset ma sostituisci solo il tono della pelle
        
        // Estrai il prefisso di genere
        let genderPrefix = avatar.gender == .male ? "male_" : "female_"
        
        // Aggiorna il corpo (body)
        let bodyBaseName = "010 body Body_color"
        avatar.skin = "\(bodyBaseName) \(skin)"
        
        // Aggiorna anche la testa con lo stesso tono di pelle
        let currentHead = avatar.head
        
        // Determina il tipo di testa (Human_male, Human_female, ecc.)
        let headTypeComponents = currentHead.components(separatedBy: " ")
        if headTypeComponents.count >= 3 {
            // Formato: "100 head Human_male light" -> estrai "Human_male"
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
        avatar.eyes = eyes
    }
    
    func setGender(_ gender: Gender) {
        avatar.gender = gender
        // Puoi anche resettare qui i layer con asset di default per il nuovo gender, se necessario
    }
    
    // MARK: - Reset
    
    func resetAvatar() {
        avatar = AvatarViewModel.defaultAvatar()
    }
    
    // MARK: - Caricamento manuale
    
    func loadAvatar(_ newAvatar: AvatarData) {
        avatar = newAvatar
    }
    
    // MARK: - Avatar di default (static func)
    
    static func defaultAvatar() -> AvatarData {
        return AvatarData(
            gender: .male,
            head: "100 head Human_male light",
            hair: "120 hair Plain black",
            skin: "010 body Body_color light",
            shirt: "035 clothes TShirt white",
            pants: "020 legs Pants black",
            shoes: "015 shoes Basic_Shoes black",
            eyes: "105 eye_color Eye_Color blue"
        )
    }
}
