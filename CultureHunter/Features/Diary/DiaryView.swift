import SwiftUI
import AVFoundation

struct DiaryView: View {
    let place: Place
    @State private var isReading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    @State private var currentDate: String = "2025-07-07 14:41:43"
    @State private var username: String = "FrancescoDiCrescenzo"
    
    // Mantieni il sintetizzatore come proprietà di stato per evitare che venga deallocato
    @State private var speechSynthesizer = AVSpeechSynthesizer()
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
                    
                    // Sezione Diary/Storia con bottone di lettura
                    HStack {
                        Text("Diary")
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
                    
                    if isReading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Riproduzione audio in corso...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 5)
                        }
                        .padding(.top, 5)
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
            stopReading()
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
    
    // Funzione per leggere il testo
    private func readText(_ text: String) {
        do {
            // Assicurati che la sessione audio sia attiva
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Crea l'utterance
            let utterance = AVSpeechUtterance(string: text)
            
            // Prova a impostare la voce italiana, altrimenti usa la voce predefinita
            if let italianVoice = AVSpeechSynthesisVoice(language: "it-IT") {
                utterance.voice = italianVoice
            } else if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
                // Fallback alla voce inglese se l'italiano non è disponibile
                utterance.voice = defaultVoice
                print("Voce italiana non disponibile, utilizzo voce inglese")
            }
            
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0 // Volume massimo
            
            // Crea un nuovo delegato e mantieni un riferimento forte
            synthesizerDelegate = SpeechSynthesizerDelegate(onComplete: {
                DispatchQueue.main.async {
                    self.isReading = false
                    print("Lettura completata")
                }
            }, onStart: {
                print("Lettura iniziata")
            }, onError: { error in
                DispatchQueue.main.async {
                    self.isReading = false
                    self.errorMessage = "Errore durante la lettura: \(error)"
                    self.showError = true
                    print("Errore durante la lettura: \(error)")
                }
            })
            
            // Assegna il delegato
            speechSynthesizer.delegate = synthesizerDelegate
            
            // Inizia a parlare
            if speechSynthesizer.isSpeaking {
                speechSynthesizer.stopSpeaking(at: .immediate)
            }
            
            // Correzione: il metodo speak(_:) non restituisce un valore booleano
            speechSynthesizer.speak(utterance)
            print("Avvio sintesi vocale")
            isReading = true
            
        } catch {
            errorMessage = "Errore di inizializzazione audio: \(error.localizedDescription)"
            showError = true
            print("Errore di inizializzazione audio: \(error)")
        }
    }
    
    // Funzione per fermare la lettura
    private func stopReading() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isReading = false
    }
}

// Delegato migliorato per la sintesi vocale
class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onComplete: () -> Void
    private let onStart: () -> Void
    private let onError: (String) -> Void
    
    init(onComplete: @escaping () -> Void, onStart: @escaping () -> Void, onError: @escaping (String) -> Void) {
        self.onComplete = onComplete
        self.onStart = onStart
        self.onError = onError
        super.init()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        onStart()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onComplete()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onError("Lettura annullata")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        onError("Lettura in pausa")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        onStart()
    }
}
