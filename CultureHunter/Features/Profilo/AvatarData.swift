//
//  AvatarData.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//
struct AvatarData : Codable{
    var name: String
    var gender: Gender
    var head: String
    var hair: String
    var skin: String
    var shirt: String
    var pants: String
    var shoes: String
    var eyes: String
    var coins: Int = 40
}

extension AvatarData: Hashable {
    static func == (lhs: AvatarData, rhs: AvatarData) -> Bool {
        return lhs.name == rhs.name &&
               lhs.gender == rhs.gender &&
               lhs.head == rhs.head &&
               lhs.hair == rhs.hair &&
               lhs.skin == rhs.skin &&
               lhs.shirt == rhs.shirt &&
               lhs.pants == rhs.pants &&
               lhs.shoes == rhs.shoes &&
               lhs.eyes == rhs.eyes &&
               lhs.coins == rhs.coins
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(gender)
        hasher.combine(head)
        hasher.combine(hair)
        hasher.combine(skin)
        hasher.combine(shirt)
        hasher.combine(pants)
        hasher.combine(shoes)
        hasher.combine(eyes)
        hasher.combine(coins)
    }
}
