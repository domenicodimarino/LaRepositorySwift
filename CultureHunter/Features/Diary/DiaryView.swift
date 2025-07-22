import SwiftUI
import AVFoundation

struct DiaryView: View {
    let poi: MappedPOI
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false

    @StateObject private var audioManager = AudioManager.shared
    @State private var dragPosition: Double = 0
    @State private var isDragging: Bool = false

    private var placeData: Place? {
        return PlacesData.shared.places.first { $0.name == poi.diaryPlaceName }
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

                            if audioManager.duration > 0 {
                                VStack(spacing: 6) {
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
                                                audioManager.seek(to: dragPosition)
                                                isDragging = false
                                            }
                                        }
                                    )
                                    .accentColor(.blue)

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

                        if let placeHistory = placeData?.history {
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

    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func playAudio() {
        if let place = placeData {
            if let audioURL = audioManager.loadAudioFromBundle(named: place.effectiveAudioName) {
                audioManager.playAudio(from: audioURL, withID: "narration")
            } else {
                errorMessage = "Audio narrativo non disponibile per questo luogo"
                showError = true
            }
        } else {
            let audioName = poi.diaryPlaceName.lowercased().replacingOccurrences(of: " ", with: "_")
            if let audioURL = audioManager.loadAudioFromBundle(named: audioName) {
                audioManager.playAudio(from: audioURL, withID: "narration")
            } else {
                errorMessage = "Audio narrativo non disponibile per questo luogo"
                showError = true
            }
        }
    }
}
