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
    
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool = false
    
    private let fileManager = FileManager.default
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var currentID: String?
    private var timer: Timer?
    
    private override init() {
        super.init()
    }
    
    func loadAudioFromBundle(named filename: String, withExtension ext: String = "mp3") -> URL? {
        if let path = Bundle.main.path(forResource: filename, ofType: ext) {
            return URL(fileURLWithPath: path)
        }
        print("❌ Audio file \(filename).\(ext) not found in bundle")
        return nil
    }
    
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
    
    func playAudio(from url: URL, withID id: String = UUID().uuidString) {
        stopAllAudio()
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayers[id] = audioPlayer
            currentID = id
            
            duration = audioPlayer.duration
            
            audioPlayer.play()
            isPlaying = true
            
            startProgressTimer()
        } catch {
            print("❌ Errore nella riproduzione dell'audio: \(error)")
        }
    }
    
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
    
    func pauseAudio() {
        guard let id = currentID, let player = audioPlayers[id] else { return }
        player.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    func resumeAudio() {
        guard let id = currentID, let player = audioPlayers[id] else { return }
        player.play()
        isPlaying = true
        startProgressTimer()
    }
    
    func seek(to time: Double) {
        guard let id = currentID, let player = audioPlayers[id] else { return }
        player.currentTime = time
        currentTime = time
    }
    
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
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
