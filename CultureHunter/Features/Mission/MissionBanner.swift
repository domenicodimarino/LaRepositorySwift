import SwiftUI

struct MissionBanner: View {
    @ObservedObject var missionViewModel: MissionViewModel

    var body: some View {
        if let mission = missionViewModel.activeMission, !mission.isCompleted {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 213, height: 111)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(21)
                    .overlay(
                        RoundedRectangle(cornerRadius: 21)
                            .inset(by: 2.5)
                            .stroke(.black, lineWidth: 5)
                    )
                
                VStack {
                    Text("Missione Giornaliera")
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.bottom, 4)
                    
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text(mission.description)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                            
                            // Mostra sempre il timer, usando la stringa dal viewModel
                            if !missionViewModel.timeLeftString.isEmpty {
                                Text("Tempo: \(missionViewModel.timeLeftString)")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(width: 213, height: 111)
        } else if let mission = missionViewModel.activeMission, mission.isCompleted {
            // Mostra missione completata
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 213, height: 111)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(21)
                    .overlay(
                        RoundedRectangle(cornerRadius: 21)
                            .inset(by: 2.5)
                            .stroke(.green, lineWidth: 5)
                    )
                VStack {
                    Text("Missione completata!")
                        .font(.body)
                        .fontWeight(.semibold)
                    Text("+\(mission.reward) monete")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            .frame(width: 213, height: 111)
        } else {
            // Nessuna missione disponibile
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 213, height: 111)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(21)
                    .overlay(
                        RoundedRectangle(cornerRadius: 21)
                            .inset(by: 2.5)
                            .stroke(.black, lineWidth: 5)
                    )
                
                VStack {
                    Text("Nessuna missione")
                        .font(.body)
                        .fontWeight(.semibold)
                    Text("Controlla più tardi!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 213, height: 111)
        }
    }
}
