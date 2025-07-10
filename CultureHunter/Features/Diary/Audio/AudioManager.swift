//
//  AudioManager.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 10/07/25.
//


import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    // Aggiungi questi per supportare la barra di progresso
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool = false
    
    private let fileManager = FileManager.default
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var currentID: String?
    private var timer: Timer?
    
    // Assicuriamoci che il singleton venga inizializzato correttamente
    private override init() {
        super.init()
    }
    
    // MARK: - Audio Bundle
    
    /// Carica un audio dal bundle dell'app
    func loadAudioFromBundle(named filename: String, withExtension ext: String = "mp3") -> URL? {
        if let path = Bundle.main.path(forResource: filename, ofType: ext) {
            return URL(fileURLWithPath: path)
        }
        print("❌ Audio file \(filename).\(ext) not found in bundle")
        return nil
    }
    
    // MARK: - Gestione audio dinamici
    
    /// Salva un audio nella directory documenti
    func saveAudio(data: Data, withName name: String) -> URL? {
        let audioDirectory = getOrCreateAudioDirectory()
        let fileURL = audioDirectory.appendingPathComponent("\(name).mp3")
        
        do {
            try data.write(to: fileURL)
            print("✅ Audio salvato in: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Errore nel salvare l'audio: \(error)")
            return nil
        }
    }
    
    /// Carica un audio dalla directory documenti
    func loadAudioFromDocuments(named name: String) -> URL? {
        let audioDirectory = getOrCreateAudioDirectory()
        let fileURL = audioDirectory.appendingPathComponent("\(name).mp3")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            print("❌ Audio file \(name).mp3 not found in documents")
            return nil
        }
    }
    
    /// Rimuove un audio dalla directory documenti
    func removeAudio(named name: String) -> Bool {
        guard let fileURL = loadAudioFromDocuments(named: name) else { return false }
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("✅ Audio rimosso: \(fileURL.path)")
            return true
        } catch {
            print("❌ Errore nella rimozione dell'audio: \(error)")
            return false
        }
    }
    
    // MARK: - Audio playback
    
    /// Riproduce un file audio
    func playAudio(from url: URL, withID id: String = UUID().uuidString) {
        stopAllAudio()
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayers[id] = audioPlayer
            currentID = id
            
            // Imposta la durata totale
            duration = audioPlayer.duration
            
            // Avvia la riproduzione
            audioPlayer.play()
            isPlaying = true
            
            // Inizia il timer per aggiornare la posizione
            startProgressTimer()
        } catch {
            print("❌ Errore nella riproduzione dell'audio: \(error)")
        }
    }
    
    /// Ferma la riproduzione di un audio
    func stopAudio(withID id: String) {
        audioPlayers[id]?.stop()
        audioPlayers.removeValue(forKey: id)
        
        if currentID == id {
            currentID = nil
            isPlaying = false
            stopProgressTimer()
            currentTime = 0
        }
    }
    
    /// Ferma tutti gli audio in riproduzione
    func stopAllAudio() {
        for (id, player) in audioPlayers {
            player.stop()
            audioPlayers.removeValue(forKey: id)
        }
        
        currentID = nil
        isPlaying = false
        stopProgressTimer()
        currentTime = 0
    }
    
    /// Metti in pausa la riproduzione corrente
    func pauseAudio() {
        guard let id = currentID, let player = audioPlayers[id] else { return }
        player.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    /// Riprende la riproduzione corrente
    func resumeAudio() {
        guard let id = currentID, let player = audioPlayers[id] else { return }
        player.play()
        isPlaying = true
        startProgressTimer()
    }
    
    /// Vai a una posizione specifica nell'audio corrente
    func seek(to time: Double) {
        guard let id = currentID, let player = audioPlayers[id] else { return }
        player.currentTime = time
        currentTime = time
    }
    
    // MARK: - Progress tracking
    
    private func startProgressTimer() {
        stopProgressTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let id = self.currentID, let player = self.audioPlayers[id] else {
                return
            }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Ottiene o crea la directory dedicata agli audio
    private func getOrCreateAudioDirectory() -> URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectory = documentsDirectory.appendingPathComponent("Audio", isDirectory: true)
        
        if !fileManager.fileExists(atPath: audioDirectory.path) {
            do {
                try fileManager.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
            } catch {
                print("❌ Impossibile creare la directory Audio: \(error)")
            }
        }
        
        return audioDirectory
    }
    
    // MARK: - AVAudioPlayerDelegate methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Trova l'ID del player che ha finito
        for (id, p) in audioPlayers {
            if p === player {
                DispatchQueue.main.async { [weak self] in
                    self?.audioPlayers.removeValue(forKey: id)
                    
                    if self?.currentID == id {
                        self?.currentID = nil
                        self?.isPlaying = false
                        self?.stopProgressTimer()
                        self?.currentTime = 0
                    }
                }
                break
            }
        }
    }
}
