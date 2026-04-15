// MARK: - File: Persistence.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import CoreData

// MARK: - PersistenceController

struct PersistenceController {

    // MARK: - Shared Instance
    static let shared = PersistenceController()

    // MARK: - Preview (in-memory)
    @MainActor
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    // MARK: - Container
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Init

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "pocketdo")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle migration or alert the user gracefully.
                fatalError("CoreData store failed to load: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Helper

    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("CoreData save failed: \(nsError), \(nsError.userInfo)")
        }
    }
}
