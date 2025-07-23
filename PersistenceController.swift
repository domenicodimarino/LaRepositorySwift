//
//  PersistenceController.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 23/07/25.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "POIModel") // nome del tuo modello .xcdatamodeld
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Errore nel caricamento del persistent store: \(error)")
            }
        }
    }
}
