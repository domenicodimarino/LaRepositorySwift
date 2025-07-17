import SwiftUI

struct BadgeView: View {
    @ObservedObject var manager: BadgeManager
    @State private var selectedBadge: BadgeModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("I tuoi badge")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            ForEach(manager.badges) { badge in
                Button(action: {
                    if badge.isUnlocked {
                        selectedBadge = badge
                    }
                }) {
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
                .buttonStyle(PlainButtonStyle())
                .disabled(!badge.isUnlocked)
            }
            Spacer()
        }
        .padding()
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(badge: badge)
        }
    }
    
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
