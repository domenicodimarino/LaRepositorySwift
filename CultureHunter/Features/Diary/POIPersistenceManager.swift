//
//  POIPersistenceManager.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 15/07/25.
//


import Foundation
import UIKit
import CoreLocation

class POIPersistenceManager {
    static let shared = POIPersistenceManager()
    
    let discoveredPOIsKey = "discoveredPOIs"
    
    // Struttura per i dati salvati in UserDefaults
    struct SavedPOIData: Codable {
        let id: UUID
        let discoveredDate: Date
        let photoFileName: String? // 👈 Usa solo il nome file, non il path completo
        let discoveredTitle: String?
        let city: String
    }
    
    // MARK: - Salvataggio POI
    
    func savePOIDiscovery(id: UUID, photo: UIImage?, city: String, title: String?) -> String? {
        // 1. Salva la foto nel filesystem se presente
            var photoPath: String? = nil
            var photoFileName: String? = nil
            
            if let photo = photo {
                let fileName = "\(id.uuidString).jpg" // Non opzionale
                photoFileName = fileName
                photoPath = savePhotoToFileSystem(photo: photo, fileName: fileName) // Passa un valore non opzionale
            }
        
        // 2. Crea l'oggetto dati
        let discoveryData = SavedPOIData(
            id: id,
            discoveredDate: Date(),
            photoFileName: photoFileName, // 👈 Salva solo il nome del file
            discoveredTitle: title,
            city: city
        )
        
        // 3. Recupera i dati esistenti
        var savedData = getSavedPOIData()
        
        // 4. Aggiorna o aggiungi il nuovo POI
        if let index = savedData.firstIndex(where: { $0.id == id }) {
            savedData[index] = discoveryData
        } else {
            savedData.append(discoveryData)
        }
        
        // 5. Salva in UserDefaults
        saveToUserDefaults(data: savedData)
        
        return photoPath
    }
    
    // MARK: - Lettura POI
    
    func isDiscovered(id: UUID) -> Bool {
        return getSavedPOIData().contains(where: { $0.id == id })
    }
    
    func getDiscoveryData(for id: UUID) -> SavedPOIData? {
        return getSavedPOIData().first(where: { $0.id == id })
    }
    
    func getAllDiscoveredPOIs() -> [SavedPOIData] {
        return getSavedPOIData()
    }
    
    // MARK: - Metodi privati
    
    private func getSavedPOIData() -> [SavedPOIData] {
        // Controlla prima la chiave corretta
        var data: Data? = UserDefaults.standard.data(forKey: discoveredPOIsKey)
        
        // Se non trova nulla, prova la chiave alternativa (con la prima maiuscola)
        if data == nil {
            data = UserDefaults.standard.data(forKey: "DiscoveredPOIs")
            // Se trova dati con la chiave alternativa, migra i dati alla chiave corretta
            if let alternativeData = data {
                UserDefaults.standard.set(alternativeData, forKey: discoveredPOIsKey)
                UserDefaults.standard.removeObject(forKey: "DiscoveredPOIs")
                print("🔄 Dati migrati da 'DiscoveredPOIs' a 'discoveredPOIs'")
            }
        }
        
        guard let finalData = data,
              let savedData = try? JSONDecoder().decode([SavedPOIData].self, from: finalData) else {
            return []
        }
        return savedData
    }
    
    private func saveToUserDefaults(data: [SavedPOIData]) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: discoveredPOIsKey)
            // Sync immediato per evitare perdite di dati
            UserDefaults.standard.synchronize()
        }
    }
    
    // Ottieni il percorso completo per un nome file
    private func getFullPath(for fileName: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("POIPhotos/\(fileName)")
        return fileURL.path
    }
    
    private func savePhotoToFileSystem(photo: UIImage, fileName: String) -> String? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryURL = documentsDirectory.appendingPathComponent("POIPhotos")
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        // Crea la directory se non esiste
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                print("❌ Errore nella creazione della directory: \(error)")
                return nil
            }
        }
        
        // Salva l'immagine come JPEG compresso
        if let imageData = photo.jpegData(compressionQuality: 0.7) {
            do {
                try imageData.write(to: fileURL)
                print("✅ Immagine salvata in: \(fileURL.path)")
                return fileURL.path
            } catch {
                print("❌ Errore nel salvataggio dell'immagine: \(error)")
                return nil
            }
        }
        
        return nil
    }
    
    // Funzione per aggiornare il POIViewModel con log di debug
    func applyPersistedDataTo(mappedPOIs: inout [MappedPOI]) {
        let savedData = getSavedPOIData()
        
        print("🔍 Trovati \(savedData.count) POI salvati in UserDefaults")
        
        if savedData.isEmpty {
            print("⚠️ ATTENZIONE: Nessun dato salvato trovato!")
            return
        }
        
        var updatedCount = 0
        
        for savedPOI in savedData {
            print("📋 POI salvato: \(savedPOI.id.uuidString) - \(savedPOI.discoveredTitle ?? "Senza titolo")")
            
            // Controlla se il POI è presente nell'array
            let matchingPOIs = mappedPOIs.filter { $0.id == savedPOI.id }
            if matchingPOIs.isEmpty {
                print("❌ POI non trovato in mappedPOIs: \(savedPOI.id.uuidString)")
            }
            
            // Verifica il file immagine
            var finalPhotoPath: String? = nil
            if let fileName = savedPOI.photoFileName {
                let path = getFullPath(for: fileName)
                let fileExists = FileManager.default.fileExists(atPath: path)
                print("   📷 Foto: \(fileExists ? "Trovata ✅" : "Mancante ❌") - FileName: \(fileName)")
                
                if fileExists {
                    finalPhotoPath = path
                }
            }
            
            // Aggiorna i POI corrispondenti
            for i in 0..<mappedPOIs.count {
                if mappedPOIs[i].id == savedPOI.id {
                    mappedPOIs[i].isDiscovered = true
                    mappedPOIs[i].discoveredTitle = savedPOI.discoveredTitle
                    mappedPOIs[i].photoPath = finalPhotoPath
                    mappedPOIs[i].discoveredDate = savedPOI.discoveredDate
                    
                    updatedCount += 1
                    print("✅ POI aggiornato: \(mappedPOIs[i].title)")
                }
            }
        }
        
        print("📊 Totale POI aggiornati: \(updatedCount) di \(savedData.count) salvati")
    }
    
    // Rimuovi i dati di un POI scoperto
    func removePOIDiscovery(id: UUID) {
        // Recupera il nome del file prima di eliminare i dati
        let savedPOI = getDiscoveryData(for: id)
        
        // Rimuovi i dati da UserDefaults
        var savedData = getSavedPOIData()
        savedData.removeAll(where: { $0.id == id })
        saveToUserDefaults(data: savedData)
        
        // Elimina il file immagine se esiste
        if let fileName = savedPOI?.photoFileName {
            let path = getFullPath(for: fileName)
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                    print("🗑️ Immagine eliminata: \(path)")
                } catch {
                    print("❌ Errore nell'eliminare l'immagine: \(error)")
                }
            }
        }
        
        print("🗑️ POI rimosso: \(id.uuidString)")
    }
    // Aggiungi questo metodo per migrare dati esistenti
    func migrateExistingData() {
        // Carica i dati esistenti
        guard let data = UserDefaults.standard.data(forKey: discoveredPOIsKey),
              let oldSavedData = try? JSONDecoder().decode([SavedPOIData].self, from: data) else {
            return
        }
        
        // Array per i dati migrati
        var migratedData: [SavedPOIData] = []
        
        for oldData in oldSavedData {
            var newData = oldData
            
            // Se il photoPath è un path completo, estrai solo il nome del file
            if let oldPath = oldData.photoFileName, oldPath.contains("/") {
                let components = oldPath.components(separatedBy: "/")
                if let fileName = components.last {
                    newData = SavedPOIData(
                        id: oldData.id,
                        discoveredDate: oldData.discoveredDate,
                        photoFileName: fileName,
                        discoveredTitle: oldData.discoveredTitle,
                        city: oldData.city
                    )
                    print("🔄 Migrato: \(fileName) da \(oldPath)")
                }
            }
            
            migratedData.append(newData)
        }
        
        // Salva i dati migrati
        saveToUserDefaults(data: migratedData)
        print("✅ Migrazione completata: \(migratedData.count) record")
    }
}
