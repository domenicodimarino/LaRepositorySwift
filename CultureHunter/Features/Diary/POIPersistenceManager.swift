import Foundation
import UIKit
import CoreLocation

class POIPersistenceManager {
    static let shared = POIPersistenceManager()
    
    let discoveredPOIsKey = "discoveredPOIs"

    struct SavedPOIData: Codable {
        let id: UUID
        let discoveredDate: Date
        let photoFileName: String?
        let discoveredTitle: String?
        let city: String
        let history: String?
    }
    
    
    func savePOIDiscovery(id: UUID, photo: UIImage?, city: String, title: String?, history: String?) -> String? {
            var photoPath: String? = nil
            var photoFileName: String? = nil
            
            if let photo = photo {
                let fileName = "\(id.uuidString).jpg"
                photoFileName = fileName
                photoPath = savePhotoToFileSystem(photo: photo, fileName: fileName)
            }
        
        let discoveryData = SavedPOIData(
            id: id,
            discoveredDate: Date(),
            photoFileName: photoFileName,
            discoveredTitle: title,
            city: city,
            history: history
        )
        
        var savedData = getSavedPOIData()
        
        if let index = savedData.firstIndex(where: { $0.id == id }) {
            savedData[index] = discoveryData
        } else {
            savedData.append(discoveryData)
        }
        
        saveToUserDefaults(data: savedData)
        
        return photoPath
    }
    
    
    func isDiscovered(id: UUID) -> Bool {
        return getSavedPOIData().contains(where: { $0.id == id })
    }
    
    func getDiscoveryData(for id: UUID) -> SavedPOIData? {
        return getSavedPOIData().first(where: { $0.id == id })
    }
    
    func getAllDiscoveredPOIs() -> [SavedPOIData] {
        return getSavedPOIData()
    }
    
    
    private func getSavedPOIData() -> [SavedPOIData] {
        var data: Data? = UserDefaults.standard.data(forKey: discoveredPOIsKey)
        
        if data == nil {
            data = UserDefaults.standard.data(forKey: "DiscoveredPOIs")
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
            UserDefaults.standard.synchronize()
        }
    }
    
    private func getFullPath(for fileName: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("POIPhotos/\(fileName)")
        return fileURL.path
    }
    
    private func savePhotoToFileSystem(photo: UIImage, fileName: String) -> String? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryURL = documentsDirectory.appendingPathComponent("POIPhotos")
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                print("❌ Errore nella creazione della directory: \(error)")
                return nil
            }
        }
        
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
            
            let matchingPOIs = mappedPOIs.filter { $0.id == savedPOI.id }
            if matchingPOIs.isEmpty {
                print("❌ POI non trovato in mappedPOIs: \(savedPOI.id.uuidString)")
            }
            
            var finalPhotoPath: String? = nil
            if let fileName = savedPOI.photoFileName {
                let path = getFullPath(for: fileName)
                let fileExists = FileManager.default.fileExists(atPath: path)
                print("   📷 Foto: \(fileExists ? "Trovata ✅" : "Mancante ❌") - FileName: \(fileName)")
                
                if fileExists {
                    finalPhotoPath = path
                }
            }
            
            for i in 0..<mappedPOIs.count {
                if mappedPOIs[i].id == savedPOI.id {
                    mappedPOIs[i].isDiscovered = true
                    mappedPOIs[i].discoveredTitle = savedPOI.discoveredTitle
                    mappedPOIs[i].photoPath = finalPhotoPath
                    mappedPOIs[i].discoveredDate = savedPOI.discoveredDate
                    mappedPOIs[i].history = savedPOI.history
                    updatedCount += 1
                    print("✅ POI aggiornato: \(mappedPOIs[i].title)")
                }
            }
        }
        
        print("📊 Totale POI aggiornati: \(updatedCount) di \(savedData.count) salvati")
    }

    func removePOIDiscovery(id: UUID) {
        let savedPOI = getDiscoveryData(for: id)
        
        var savedData = getSavedPOIData()
        savedData.removeAll(where: { $0.id == id })
        saveToUserDefaults(data: savedData)
        
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
   
    func migrateExistingData() {
        guard let data = UserDefaults.standard.data(forKey: discoveredPOIsKey),
              let oldSavedData = try? JSONDecoder().decode([SavedPOIData].self, from: data) else {
            return
        }
        
        var migratedData: [SavedPOIData] = []
        
        for oldData in oldSavedData {
            var newData = oldData
            
            if let oldPath = oldData.photoFileName, oldPath.contains("/") {
                let components = oldPath.components(separatedBy: "/")
                if let fileName = components.last {
                    newData = SavedPOIData(
                        id: oldData.id,
                        discoveredDate: oldData.discoveredDate,
                        photoFileName: fileName,
                        discoveredTitle: oldData.discoveredTitle,
                        city: oldData.city,
                        history: oldData.history
                    )
                    print("🔄 Migrato: \(fileName) da \(oldPath)")
                }
            }
            
            migratedData.append(newData)
        }
        
        saveToUserDefaults(data: migratedData)
        print("✅ Migrazione completata: \(migratedData.count) record")
    }
    // Salva o aggiorna solo la storia per un POI già scoperto
    func savePOIHistory(id: UUID, history: String?) {
        var savedData = getSavedPOIData()
        if let index = savedData.firstIndex(where: { $0.id == id }) {
            let old = savedData[index]
            let updated = SavedPOIData(
                id: old.id,
                discoveredDate: old.discoveredDate,
                photoFileName: old.photoFileName,
                discoveredTitle: old.discoveredTitle,
                city: old.city,
                history: history // aggiorna la storia!
            )
            savedData[index] = updated
            saveToUserDefaults(data: savedData)
        }
    }

    // PATCH: carica la storia persistente per un POI
    func loadPOIHistory(id: UUID) -> String? {
        return getSavedPOIData().first(where: { $0.id == id })?.history
    }
}
