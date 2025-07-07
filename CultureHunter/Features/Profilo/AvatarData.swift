//
//  AvatarData.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//
struct AvatarData : Codable{
    var name: String // Nome dell'avatar
    var gender: Gender
    var head: String
    var hair: String // nome asset capelli selezionato
    var skin: String // nome asset carnagione selezionata
    var shirt: String // nome asset maglietta selezionata
    var pants: String // nome asset pantaloni selezionati
    var shoes: String // nome asset scarpe selezionate
    var eyes: String // nome asset occhi selezionati
    var coins: Int = 40 // Monete del giocatore (default 40)
}
