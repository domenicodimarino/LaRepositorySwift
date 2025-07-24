import Foundation
import UIKit
import CoreData

class POIPersistenceManager {
    static let shared = POIPersistenceManager()

    // Salva o aggiorna la scoperta di un POI
    func savePOIDiscovery(
        id: UUID,
        photo: UIImage?,
        city: String,
        title: String?,
        history: String?,
        context: NSManagedObjectContext
    ) -> String? {
        let fetchRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let poi: POIEntity
        if let found = (try? context.fetch(fetchRequest))?.first {
            poi = found
        } else {
            poi = POIEntity(context: context)
            poi.id = id
        }
        poi.city = city
        poi.discoveredTitle = title
        poi.isDiscovered = true
        poi.discoveredDate = Date()
        poi.history = history

        // Salva la foto se presente
        var photoPath: String? = nil
        if let photo = photo {
            let fileName = "\(id.uuidString).jpg"
            photoPath = savePhotoToFileSystem(photo: photo, fileName: fileName)
        }
        poi.photoPath = photoPath

        do {
            try context.save()
        } catch {
            print("Errore nel salvataggio POI in CoreData: \(error)")
        }
        return photoPath
    }

    // Verifica se il POI è stato scoperto
    func isDiscovered(id: UUID, context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return ((try? context.fetch(fetchRequest))?.first?.isDiscovered ?? false)
    }

    // Recupera i dati di scoperta del POI
    func getDiscoveryData(for id: UUID, context: NSManagedObjectContext) -> POIEntity? {
        let fetchRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? context.fetch(fetchRequest))?.first
    }

    // Recupera tutti i POI scoperti
    func getAllPOIs(context: NSManagedObjectContext) -> [POIEntity] {
        let fetchRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }

    // Rimuove la scoperta di un POI (e la relativa foto)
    func removePOIDiscovery(id: UUID, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let poi = (try? context.fetch(fetchRequest))?.first else { return }

        // Rimuovi la foto dal file system
        if let photoPath = poi.photoPath, FileManager.default.fileExists(atPath: photoPath) {
            do {
                try FileManager.default.removeItem(atPath: photoPath)
                print("🗑️ Immagine eliminata: \(photoPath)")
            } catch {
                print("❌ Errore nell'eliminare l'immagine: \(error)")
            }
        }

        // Cancella il POI dal database
        context.delete(poi)
        try? context.save()
        print("🗑️ POI rimosso: \(id.uuidString)")
    }

    // Salva la storia (history) di un POI già scoperto
    func savePOIHistory(id: UUID, history: String?, context: NSManagedObjectContext) {
        guard let poi = getDiscoveryData(for: id, context: context) else { return }
        poi.history = history
        try? context.save()
    }

    // Carica la storia persistente per un POI
    func loadPOIHistory(id: UUID, context: NSManagedObjectContext) -> String? {
        return getDiscoveryData(for: id, context: context)?.history
    }

    // ----------- FOTO ----------
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
    func bootstrapInitialPOIsIfNeeded(context: NSManagedObjectContext) {
            let fetchRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
            fetchRequest.fetchLimit = 1
            let count = (try? context.count(for: fetchRequest)) ?? 0
            if count == 0 {
                print("🌱 Primo avvio: inserisco tutti i POI iniziali in CoreData")
                for poi in POIDefaults.all {
                    print("Inserisco \(poi.diaryPlaceName) - yearBuilt: \(poi.yearBuilt)")
                    let entity = POIEntity(context: context)
                    entity.id = poi.id
                    entity.city = poi.city
                    entity.province = poi.province
                    entity.title = poi.title
                    entity.diaryPlaceName = poi.diaryPlaceName
                    entity.discoveredTitle = poi.discoveredTitle
                    entity.isDiscovered = poi.isDiscovered
                    entity.latitude = poi.latitude ?? 0
                    entity.longitude = poi.longitude ?? 0
                    entity.photoPath = poi.photoPath
                    entity.discoveredDate = poi.discoveredDate
                    entity.history = nil
                    entity.imageName = poi.imageName
                    entity.yearBuilt = poi.yearBuilt
                }
                try? context.save()
            }
        }
}
