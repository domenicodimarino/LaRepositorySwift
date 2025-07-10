import SwiftUI
import AVFoundation

struct DiaryView: View {
    let place: Place
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    @State private var currentDate: String = "2025-07-10 13:00:15"
    
    // Usa l'AudioManager originale come ObservableObject
    @StateObject private var audioManager = AudioManager.shared
    
    // Stato per il valore di trascinamento
    @State private var dragPosition: Double = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Immagine principale dagli Assets
                Image(place.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 15) {
                    // Titolo
                    Text(place.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Informazioni rapide
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Costruzione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(place.yearBuilt)
                                .font(.headline)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Posizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(place.location)
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                    
                    // Sezione Diary/Storia con bottone di audio
                    VStack(spacing: 10) {
                        HStack {
                            Text("Diary")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Bottone per l'audio pre-registrato
                            Button(action: {
                                if audioManager.isPlaying {
                                    audioManager.pauseAudio()
                                } else if audioManager.currentTime > 0 {
                                    audioManager.resumeAudio()
                                } else {
                                    playAudio()
                                }
                            }) {
                                HStack {
                                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                    Text(audioManager.isPlaying ? "Pausa" : (audioManager.currentTime > 0 ? "Riprendi" : "Ascolta"))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(audioManager.isPlaying ? Color.red : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        
                        // BARRA DI PROGRESSO AUDIO INTERATTIVA
                        if audioManager.duration > 0 {
                            VStack(spacing: 6) {
                                // Barra di progresso con funzionalità di seek
                                Slider(
                                    value: Binding(
                                        get: { isDragging ? dragPosition : audioManager.currentTime },
                                        set: { newValue in
                                            dragPosition = newValue
                                            isDragging = true
                                        }
                                    ),
                                    in: 0...max(0.1, audioManager.duration),
                                    onEditingChanged: { editing in
                                        if !editing && isDragging {
                                            // Quando il trascinamento finisce, imposta la nuova posizione
                                            audioManager.seek(to: dragPosition)
                                            isDragging = false
                                        }
                                    }
                                )
                                .accentColor(.blue)
                                
                                // Etichette temporali
                                HStack {
                                    Text(formatTime(isDragging ? dragPosition : audioManager.currentTime))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(formatTime(audioManager.duration))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.bottom, 5)
                        }
                    }
                    
                    Text(place.history)
                        .font(.body)
                        .lineSpacing(5)
                    
                    // Data di visita
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Data della mia visita")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(currentDate)
                            .font(.headline)
                    }
                    .padding(.top, 15)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
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
        .onDisappear {
            // Ferma l'audio quando la vista scompare
            audioManager.stopAllAudio()
        }
        .onAppear {
            // Attiva l'audio della sessione
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
    
    // Funzione per avviare la riproduzione audio
    private func playAudio() {
        // Usa effectiveAudioName dalla struttura Place
        if let audioURL = audioManager.loadAudioFromBundle(named: place.effectiveAudioName) {
            audioManager.playAudio(from: audioURL, withID: "narration")
        } else {
            errorMessage = "Audio narrativo non disponibile per questo luogo"
            showError = true
        }
    }
    
    // Formatta il tempo in formato MM:SS
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
