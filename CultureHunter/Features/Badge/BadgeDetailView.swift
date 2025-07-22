import SwiftUI
import AVFoundation

struct BadgeDetailView: View {
    @Binding var badge: BadgeModel
    @ObservedObject var manager: BadgeManager
    var mappedPOIs: [MappedPOI] // <-- AGGIUNGI QUESTO PARAMETRO!

    @State private var isReading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var synthesizerDelegate: SpeechSynthesizerDelegate?
    @State private var loadingStory: Bool = false
    @State private var localCityStory: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(badge.cityName)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 8)

                // Se la storia c'è, la mostra!
                if let cityStory = localCityStory, !cityStory.isEmpty {
                    HStack {
                        Text("Storia della città")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            if isReading {
                                stopReading()
                            } else {
                                readText(cityStory)
                            }
                        }) {
                            HStack {
                                Image(systemName: isReading ? "pause.fill" : "play.fill")
                                Text(isReading ? "Stop" : "Ascolta")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isReading ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, 6)

                    Text(cityStory)
                        .font(.title3)
                        .padding(.bottom, 16)
                } else if loadingStory {
                    ProgressView("Caricamento storia...")
                        .padding(.bottom, 16)
                } else {
                    Text("Storia non disponibile")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.bottom, 16)
                }

                if !badge.discoveredImageNames.isEmpty {
                    Text("Le tue immagini dei POI")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(badge.discoveredImageNames, id: \.self) { imgName in
                                Image(imgName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                } else {
                    Text("Non hai ancora caricato immagini dei POI.")
                        .foregroundColor(.gray)
                        .italic()
                }

                Spacer()
            }
            .padding()
        }
        .onDisappear { stopReading() }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                errorMessage = "Errore di inizializzazione audio: \(error.localizedDescription)"
                showError = true
            }

            // Mostra subito la storia se già presente
            if !badge.cityStory.isEmpty {
                localCityStory = badge.cityStory
            } else if !loadingStory {
                loadingStory = true
                manager.fetchCityStoryIfNeeded(for: badge.cityName, mappedPOIs: mappedPOIs) { storia in
                    DispatchQueue.main.async {
                        loadingStory = false
                        if let storia = storia, !storia.isEmpty {
                            localCityStory = storia
                            badge.cityStory = storia // Aggiorna anche il binding!
                            manager.saveBadgesProgress()
                        }
                    }
                }
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

    private func readText(_ text: String) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let utterance = AVSpeechUtterance(string: text)
            if let italianVoice = AVSpeechSynthesisVoice(language: "it-IT") {
                utterance.voice = italianVoice
            } else if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
                utterance.voice = defaultVoice
            }
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0

            synthesizerDelegate = SpeechSynthesizerDelegate(
                onComplete: {
                    DispatchQueue.main.async { self.isReading = false }
                },
                onStart: {},
                onError: { error in
                    DispatchQueue.main.async {
                        self.isReading = false
                        self.errorMessage = "Errore durante la lettura: \(error)"
                        self.showError = true
                    }
                }
            )

            speechSynthesizer.delegate = synthesizerDelegate

            if speechSynthesizer.isSpeaking {
                speechSynthesizer.stopSpeaking(at: .immediate)
            }
            speechSynthesizer.speak(utterance)
            isReading = true
        } catch {
            errorMessage = "Errore di inizializzazione audio: \(error.localizedDescription)"
            showError = true
        }
    }

    private func stopReading() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isReading = false
    }
}
