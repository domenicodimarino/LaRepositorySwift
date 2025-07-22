import SwiftUI

struct MissionBanner: View {
    @ObservedObject var missionViewModel: MissionViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Group {
            if missionViewModel.activeMission == nil {
                // Nessuna missione disponibile (tema scuro incluso)
                let backgroundColor = colorScheme == .dark ? Color(white: 0.15) : Color(red: 0.85, green: 0.85, blue: 0.85)
                let borderColor = colorScheme == .dark ? Color.white.opacity(0.4) : .black
                let captionColor = colorScheme == .dark ? Color.white.opacity(0.7) : .secondary
                
                missionContainer(
                    background: backgroundColor,
                    border: borderColor,
                    content: {
                        VStack {
                            Text("Nessuna missione")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("Controlla più tardi!")
                                .font(.caption)
                                .foregroundColor(captionColor)
                        }
                    }
                )
            }

            else if let mission = missionViewModel.activeMission, mission.isCompleted {
                // MISSIONE COMPLETATA!!
                missionContainer(
                    background: Color.green.opacity(0.2),
                    border: .green,
                    content: {
                        VStack {
                            Text("Missione completata!")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("+\(mission.reward) monete")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                )
            }
            else if missionViewModel.timeLeftString == "Tempo scaduto!" {
                // MISSIONE SCADUTA!
                missionContainer(
                    background: Color.red.opacity(0.2),
                    border: .red,
                    content: {
                        VStack {
                            Text("Missione scaduta!")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("Tempo esaurito")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                )
            }
            else if let mission = missionViewModel.activeMission {
                // MISSIONE IN CORSO!
                missionContainer(
                    background: Color(red: 0.85, green: 0.85, blue: 0.85),
                    border: .black,
                    content: {
                        VStack {
                            Text("Missione Giornaliera")
                                .font(.body)
                                .fontWeight(.semibold)
                                .padding(.bottom, 4)
                                .foregroundColor(.primary)
                            
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
                                        .foregroundColor(.primary)
                                    
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
                )
            }
        }
    }
    
    // Helper function to create consistent mission containers
    private func missionContainer<Content: View>(
        background: Color,
        border: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 213, height: 111)
                .background(background)
                .cornerRadius(21)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .inset(by: 2.5)
                        .stroke(border, lineWidth: 5)
                )
            
            content()
        }
        .frame(width: 213, height: 111)
        .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2)
    }
}
