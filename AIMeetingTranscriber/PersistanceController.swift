//
//  PersistanceController.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 01/01/26.
//

internal import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        // ⛔️ GANTI dengan NAMA .xcdatamodeld lu
        container = NSPersistentContainer(name: "MeetingModel")

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        }
        print("Entities:", container.managedObjectModel.entitiesByName.keys)
    }
}
