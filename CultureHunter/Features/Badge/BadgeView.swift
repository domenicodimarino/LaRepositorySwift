//
//  BadgeView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//
import SwiftUI

struct BadgeView: View {
    @ObservedObject var manager: BadgeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("I tuoi badge")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            ForEach(manager.badges) { badge in
                HStack(spacing: 24) {
                    Image(badge.badgeImageName)
                        .resizable()
                        .frame(width: 128, height: 128)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(badge.cityName)
                            .font(.title2)
                            .bold()
                        if let unlockedDate = badge.unlockedDate, badge.isUnlocked {
                            Text(dateString(unlockedDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Text(badge.progressText)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding()
    }
    
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(manager: BadgeManager())
    }
}
