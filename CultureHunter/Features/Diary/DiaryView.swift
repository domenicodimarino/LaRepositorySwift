import SwiftUI
import AVFoundation

struct DiaryView: View {
    let poi: MappedPOI
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false

    @StateObject private var audioManager = AudioManager.shared
    @State private var dragPosition: Double = 0
    @State private var isDragging: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // FOTO TOP: se scoperto mostra due immagini affiancate, se no solo la locked
                HStack(spacing: 8) {
                    Image("poi_locked")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    if poi.isDiscovered, let photoPath = poi.photoPath, let img = UIImage(contentsOfFile: photoPath) {
                        Divider()
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(poi.diaryPlaceName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Posizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(poi.address)
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                    // Diary/History con audio (opzionale: se hai l'audio associato)
                    VStack(spacing: 10) {
                        HStack {
                            Text("Diary")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        // Qui va la logica audio se desideri (già presente nel tuo file originale)
                    }
                }
                .padding(.horizontal)
                
                // Data di scoperta
                VStack(alignment: .leading, spacing: 5) {
                    Text("Data della scoperta")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(poi.discoveredDate != nil ? formatDate(poi.discoveredDate!) : "--/--/----")
                        .font(.headline)
                }
                .padding(.top, 10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Diary")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .onDisappear { audioManager.stopAllAudio() }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                errorMessage = "Errore di inizializzazione audio: \(error.localizedDescription)"
                showError = true
            }
        }
        .alert(isPresented: $showError, content: {
            Alert(
                title: Text("Errore Audio"),
                message: Text(errorMessage ?? "Si è verificato un errore sconosciuto"),
                dismissButton: .default(Text("OK"))
            )
        })
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
