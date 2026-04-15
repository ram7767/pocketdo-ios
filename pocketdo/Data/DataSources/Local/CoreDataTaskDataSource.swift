// MARK: - File: Data/DataSources/Local/CoreDataTaskDataSource.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import CoreData
import Foundation

// MARK: - CoreDataTaskDataSource

/// Implements both `LocalTaskDataSource` and `LocalTagDataSource`
/// using CoreData entities (TaskEntity, TagEntity, AttachmentEntity).
/// Many-to-many Task ↔ Tag relationship is handled transparently.
final class CoreDataTaskDataSource: LocalTaskDataSource, LocalTagDataSource {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // ─────────────────────────────────────
    // MARK: - LocalTaskDataSource
    // ─────────────────────────────────────

    func fetchAll() throws -> [TodoTask] {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }

    func insert(_ task: TodoTask) throws {
        // Prevent duplicates
        if let _ = try? fetchTaskEntity(id: task.id) { return }

        let entity = TaskEntity(context: context)
        applyDomain(task, to: entity)
        try context.save()
    }

    func update(_ task: TodoTask) throws {
        guard let entity = try? fetchTaskEntity(id: task.id) else {
            throw AppError.fetchFailed
        }
        applyDomain(task, to: entity)
        try context.save()
    }

    func delete(id: String) throws {
        guard let entity = try? fetchTaskEntity(id: id) else {
            throw AppError.deleteFailed
        }
        context.delete(entity)
        try context.save()
    }

    func markCompleted(id: String) throws {
        guard let entity = try? fetchTaskEntity(id: id) else {
            throw AppError.fetchFailed
        }
        entity.statusRaw    = TaskStatus.completed.rawValue
        entity.completedAt  = Date()
        entity.updatedAt    = Date()
        try context.save()
    }

    func search(query: String, tagIDs: [String]) throws -> [TodoTask] {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]

        var subPredicates: [NSPredicate] = []

        if !query.isEmpty {
            subPredicates.append(
                NSPredicate(format: "title CONTAINS[cd] %@", query)
            )
        }

        if !tagIDs.isEmpty {
            subPredicates.append(
                NSPredicate(format: "ANY tags.id IN %@", tagIDs)
            )
        }

        if !subPredicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
        }

        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }

    // ─────────────────────────────────────
    // MARK: - LocalTagDataSource
    // ─────────────────────────────────────

    func fetchAll() throws -> [Tag] {
        let request = TagEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TagEntity.name, ascending: true)]
        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }

    func insert(_ tag: Tag) throws {
        // Idempotent — skip if already exists
        if let existing = try? fetchTagEntity(id: tag.id), existing != nil { return }
        let entity = TagEntity(context: context)
        entity.id       = tag.id
        entity.name     = tag.name
        entity.colorHex = tag.colorHex
        try context.save()
    }


    // ─────────────────────────────────────
    // MARK: - Private Helpers
    // ─────────────────────────────────────

    private func fetchTaskEntity(id: String) throws -> TaskEntity? {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func fetchTagEntity(id: String) throws -> TagEntity? {
        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    /// Applies a domain `TodoTask` onto an existing or new `TaskEntity`.
    /// Also handles the many-to-many tag sync.
    private func applyDomain(_ task: TodoTask, to entity: TaskEntity) {
        entity.id               = task.id
        entity.title            = task.title
        entity.taskDescription  = task.description
        entity.priorityRaw      = task.priority.rawValue
        entity.statusRaw        = task.status.rawValue
        entity.deadline         = task.deadline
        entity.createdAt        = task.createdAt
        entity.updatedAt        = Date()
        entity.completedAt      = task.completedAt
        entity.isSynced         = task.isSynced

        // ── Tags (many-to-many) ──────────────────────────
        // Clear existing relationship, then fetch-or-create each tag
        entity.tags = NSSet()
        var tagEntities: [TagEntity] = []
        for tag in task.tags {
            if let existing = try? fetchTagEntity(id: tag.id) {
                tagEntities.append(existing)
            } else {
                let newTag = TagEntity(context: context)
                newTag.id       = tag.id
                newTag.name     = tag.name
                newTag.colorHex = tag.colorHex
                tagEntities.append(newTag)
            }
        }
        entity.addToTags(NSSet(array: tagEntities))

        // ── Attachments (one-to-many) ────────────────────
        // Remove orphaned attachments not in current list
        let existingIDs = Set(task.attachments.map { $0.id })
        if let currentAttachments = entity.attachments as? Set<AttachmentEntity> {
            currentAttachments
                .filter { !existingIDs.contains($0.id ?? "") }
                .forEach { context.delete($0) }
        }
        for att in task.attachments {
            let attReq = AttachmentEntity.fetchRequest()
            attReq.predicate = NSPredicate(format: "id == %@", att.id)
            attReq.fetchLimit = 1
            let attEntity = (try? context.fetch(attReq).first) ?? AttachmentEntity(context: context)
            attEntity.id         = att.id
            attEntity.fileName   = att.fileName
            attEntity.fileURL    = att.fileURL
            attEntity.fileType   = att.fileType
            attEntity.uploadedAt = att.uploadedAt
            attEntity.task       = entity
        }
    }
}

// ─────────────────────────────────────
// MARK: - NSManagedObject → Domain Mappers
// ─────────────────────────────────────

extension TaskEntity {
    func toDomain() -> TodoTask {
        let tagDomains = (tags as? Set<TagEntity>)?
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
            .map { $0.toDomain() } ?? []
        let attachmentDomains = (attachments as? Set<AttachmentEntity>)?
            .sorted { ($0.uploadedAt ?? Date.distantPast) < ($1.uploadedAt ?? Date.distantPast) }
            .map { $0.toDomain() } ?? []

        var task = TodoTask(
            id:          id ?? UUID().uuidString,
            title:       title ?? "",
            description: taskDescription ?? "",
            priority:    Priority(rawValue: priorityRaw ?? "Medium") ?? .medium,
            status:      TaskStatus(rawValue: statusRaw ?? "Pending") ?? .pending,
            tags:        tagDomains,
            deadline:    deadline,
            attachments: attachmentDomains
        )
        // Restore timestamps from stored values
        task = TodoTask._restore(
            id:          task.id,
            title:       task.title,
            description: task.description,
            priority:    task.priority,
            status:      task.status,
            tags:        tagDomains,
            deadline:    task.deadline,
            attachments: attachmentDomains,
            createdAt:   createdAt ?? Date(),
            updatedAt:   updatedAt ?? Date(),
            completedAt: completedAt,
            isSynced:    isSynced
        )
        return task
    }
}

extension TagEntity {
    func toDomain() -> Tag {
        Tag(id: id ?? UUID().uuidString,
            name: name ?? "",
            colorHex: colorHex ?? "#3525CD")
    }
}

extension AttachmentEntity {
    func toDomain() -> TaskAttachment {
        TaskAttachment(
            id:       id ?? UUID().uuidString,
            fileName: fileName ?? "",
            fileURL:  fileURL ?? "",
            fileType: fileType ?? "file"
        )
    }
}
