import SwiftUI
import AVFoundation

struct DiaryView: View {
    let poi: MappedPOI
    @ObservedObject var viewModel: POIViewModel
    @Environment(\.managedObjectContext) private var context
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    @State private var isReading: Bool = false
    @State private var loadingHistory: Bool = false
    @State private var localHistory: String? = nil

    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var synthesizerDelegate: SpeechSynthesizerDelegate?

    private var placeData: Place? {
        PlacesData.shared.places.first { $0.name == poi.diaryPlaceName }
    }

    var body: some View {
        ZStack {
            ScrollView {
                let isIPad = UIDevice.current.userInterfaceIdiom == .pad
                let imageHeight: CGFloat = isIPad ? 280 : 180

                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 0) {
                        GeometryReader { geometry in
                            HStack(spacing: 8) {
                                Image(poi.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width / 2 - 4, height: imageHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                if poi.isDiscovered, let photoPath = poi.photoPath, let img = UIImage(contentsOfFile: photoPath) {
                                    Divider()
                                    Image(uiImage: img)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width / 2 - 4, height: imageHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Spacer()
                                        .frame(width: geometry.size.width / 2 - 4)
                                }
                            }
                        }
                    }
                    .frame(height: imageHeight)

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
                        VStack(spacing: 10) {
                            HStack {
                                Text("Storia")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    if isReading {
                                        stopReading()
                                    } else if let placeHistory = localHistory {
                                        readText(placeHistory)
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
                        }

                        if loadingHistory {
                            ProgressView("Caricamento storia...")
                        } else if let placeHistory = localHistory {
                            Text(placeHistory)
                                .font(.body)
                                .lineSpacing(5)
                        } else {
                            Text("Informazioni storiche non disponibili")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Data della scoperta")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(poi.discoveredDate != nil ? formatDate(poi.discoveredDate!) : "--/--/----")
                            .font(.headline)
                    }
                    .padding([.horizontal, .top], 16)
                    .padding(.bottom, 30)
                }
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
        .onDisappear { stopReading() }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                errorMessage = "Errore di inizializzazione audio: \(error.localizedDescription)"
                showError = true
            }

            // PATCH: Carica la storia persistente, oppure genera SOLO SE NON ESISTE!
            if let savedHistory = viewModel.persistenceManager.loadPOIHistory(id: poi.id, context: context) {
                localHistory = savedHistory
            } else if let history = poi.history, !history.isEmpty {
                localHistory = history
            } else if !loadingHistory {
                loadingHistory = true
                fetchHistoryForPOI(poi: poi) { storia in
                    DispatchQueue.main.async {
                        loadingHistory = false
                        if let storia = storia, !storia.isEmpty {
                            localHistory = storia
                            viewModel.updateHistory(for: poi.id, history: storia)
                            viewModel.persistenceManager.savePOIHistory(id: poi.id, history: storia, context: context)
                        }
                    }
                }
            }
        }
        .onReceive(viewModel.$mappedPOIs) { mappedPOIs in
            // Aggiorna la storia locale se cambia nel modello!
            if let updatedPOI = mappedPOIs.first(where: { $0.id == poi.id }) {
                localHistory = updatedPOI.history
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

    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func readText(_ text: String) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let utterance = AVSpeechUtterance(string: text)
            if let italianVoice = AVSpeechSynthesisVoice(language: "it-IT") {
                utterance.voice = italianVoice
            } else if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
                utterance.voice = defaultVoice
                print("Voce italiana non disponibile, utilizzo voce inglese")
            }
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            synthesizerDelegate = SpeechSynthesizerDelegate(onComplete: {
                DispatchQueue.main.async {
                    self.isReading = false
                }
            }, onStart: {}, onError: { error in
                DispatchQueue.main.async {
                    self.isReading = false
                    self.errorMessage = "Errore durante la lettura: \(error)"
                    self.showError = true
                }
            })
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
