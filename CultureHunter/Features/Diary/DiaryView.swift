import SwiftUI
import AVFoundation

struct DiaryView: View {
    let place: Place
    @State private var isReading: Bool = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    // Mantenere un riferimento forte al delegato
    @State private var synthesizerDelegate: SpeechSynthesizerDelegate?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Immagine principale
                AsyncImage(url: URL(string: place.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 250)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 250)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                
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
                    
                    // Sezione Diary/Storia con data corrente
                    HStack {
                        Text("Storia")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Bottone per la lettura vocale
                        Button(action: {
                            if isReading {
                                stopReading()
                            } else {
                                readText(place.history)
                            }
                        }) {
                            HStack {
                                Image(systemName: isReading ? "stop.fill" : "play.fill")
                                Text(isReading ? "Stop" : "Ascolta")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isReading ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 5)
                    
                    Text(place.history)
                        .font(.body)
                        .lineSpacing(5)
                    
                    // Data di visita con data corrente
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Data della mia visita")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("2025-07-07 14:17:50")
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
            // Ferma la lettura quando si esce dalla vista
            stopReading()
        }
    }
    
    // Funzione per leggere il testo
    private func readText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT") // Imposta la lingua italiana
        utterance.rate = 0.5 // Velocità di lettura (da 0.0 a 1.0)
        utterance.pitchMultiplier = 1.0 // Tono della voce
        utterance.volume = 1.0 // Volume (da 0.0 a 1.0)
        
        // Resetta il delegato
        speechSynthesizer.delegate = nil
        
        // Crea un nuovo delegato e mantiene un riferimento forte
        synthesizerDelegate = SpeechSynthesizerDelegate(onComplete: {
            DispatchQueue.main.async {
                self.isReading = false
            }
        })
        
        // Assegna il delegato
        speechSynthesizer.delegate = synthesizerDelegate
        
        // Inizia a parlare
        speechSynthesizer.speak(utterance)
        isReading = true
    }
    
    // Funzione per fermare la lettura
    private func stopReading() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isReading = false
    }
}

// Delegato per gestire gli eventi del sintetizzatore vocale
class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        super.init()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onComplete()
    }
}

// Anteprima per SwiftUI Canvas
struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiaryView(place: PlacesData.shared.places[0])
        }
    }
}
