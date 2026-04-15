// MARK: - File: Domain/Entities/Entities.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - Priority

enum Priority: String, CaseIterable, Codable, Identifiable, Comparable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self { case .low: return 0; case .medium: return 1; case .high: return 2 }
    }

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    var icon: String {
        switch self { case .low: return "arrow.down"; case .medium: return "minus"; case .high: return "arrow.up" }
    }
}

// MARK: - Task Status

enum TaskStatus: String, Codable, CaseIterable {
    case pending   = "Pending"
    case completed = "Completed"
    case overdue   = "Overdue"
}

// MARK: - Tag

struct Tag: Identifiable, Codable, Hashable, Equatable {
    let id: String
    var name: String
    var colorHex: String    // e.g. "#3525CD"

    init(id: String = UUID().uuidString, name: String, colorHex: String = "#3525CD") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    static func == (lhs: Tag, rhs: Tag) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Attachment

struct TaskAttachment: Identifiable, Codable, Hashable {
    let id: String
    var fileName: String
    var fileURL: String     // local file path or remote URL
    var fileType: String    // "image", "pdf", "doc", etc.
    var uploadedAt: Date

    init(id: String = UUID().uuidString, fileName: String, fileURL: String, fileType: String = "file") {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.fileType = fileType
        self.uploadedAt = Date()
    }
}

// MARK: - TodoTask

struct TodoTask: Identifiable, Codable, Hashable, Equatable {
    let id: String
    var title: String
    var description: String
    var priority: Priority
    var status: TaskStatus
    var tags: [Tag]
    var deadline: Date?
    var attachments: [TaskAttachment]
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var isSynced: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        priority: Priority = .medium,
        status: TaskStatus = .pending,
        tags: [Tag] = [],
        deadline: Date? = nil,
        attachments: [TaskAttachment] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.tags = tags
        self.deadline = deadline
        self.attachments = attachments
        self.createdAt = Date()
        self.updatedAt = Date()
        self.completedAt = nil
        self.isSynced = false
    }

    var isCompleted: Bool { status == .completed }

    var computedStatus: TaskStatus {
        if status == .completed { return .completed }
        if let deadline = deadline, deadline < Date() { return .overdue }
        return .pending
    }

    static func == (lhs: TodoTask, rhs: TodoTask) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // MARK: - Internal restore (CoreData mapper only)
    /// Rebuilds a TodoTask with exact timestamps from persistent store,
    /// bypassing the `createdAt = Date()` default in the public `init`.
    static func _restore(
        id: String,
        title: String,
        description: String,
        priority: Priority,
        status: TaskStatus,
        tags: [Tag],
        deadline: Date?,
        attachments: [TaskAttachment],
        createdAt: Date,
        updatedAt: Date,
        completedAt: Date?,
        isSynced: Bool
    ) -> TodoTask {
        var t = TodoTask(
            id: id, title: title, description: description,
            priority: priority, status: status,
            tags: tags, deadline: deadline, attachments: attachments
        )
        t.createdAt   = createdAt
        t.updatedAt   = updatedAt
        t.completedAt = completedAt
        t.isSynced    = isSynced
        return t
    }
}

// MARK: - User

struct User: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var email: String
    var avatarURL: String?
    var isPremium: Bool
    var joinedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        avatarURL: String? = nil,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.isPremium = isPremium
        self.joinedAt = Date()
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first.map(String.init) ?? ""
        let last  = parts.count > 1 ? String(parts.last!.prefix(1)) : ""
        return (String(first.prefix(1)) + last).uppercased()
    }
}

// MARK: - Subscription Plan

struct SubscriptionPlan: Identifiable {
    let id: String
    let name: String
    let price: String
    let period: String    // "month" or "year"
    let savings: String?  // e.g. "Save 40%"
    let isRecommended: Bool
    let features: [String]
}

// MARK: - Sync Status

enum SyncStatus: String, Codable {
    case synced   = "Up to date"
    case syncing  = "Syncing…"
    case pending  = "Changes pending"
    case failed   = "Sync failed"
    case offline  = "Offline"
}

// MARK: - Mock Data

extension TodoTask {
    static let mockTasks: [TodoTask] = [
        TodoTask(
            title: "Design authentication flow",
            description: "Create wireframes and finalize the UX for login, signup and guest access.",
            priority: .high,
            status: .pending,
            tags: [Tag(name: "Design", colorHex: "#3525CD"), Tag(name: "UX", colorHex: "#006E2F")],
            deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        ),
        TodoTask(
            title: "Set up project architecture",
            description: "Configure MVVM + Clean Architecture with dependency injection.",
            priority: .high,
            status: .completed,
            tags: [Tag(name: "Dev", colorHex: "#3525CD")],
            deadline: Calendar.current.date(byAdding: .day, value: -1, to: Date())
        ),
        TodoTask(
            title: "Implement dashboard charts",
            description: "Use Apple Charts framework for pie chart and progress ring.",
            priority: .medium,
            status: .pending,
            tags: [Tag(name: "Dev", colorHex: "#3525CD"), Tag(name: "Charts", colorHex: "#F59E0B")],
            deadline: Calendar.current.date(byAdding: .day, value: 3, to: Date())
        ),
        TodoTask(
            title: "Write unit tests for use cases",
            description: "Cover AddTaskUseCase, FetchTasksUseCase, and LoginUseCase.",
            priority: .low,
            status: .pending,
            tags: [Tag(name: "Testing", colorHex: "#EF4444")],
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ),
        TodoTask(
            title: "Review design system tokens",
            description: "Audit all color and spacing tokens in AppTheme.swift.",
            priority: .medium,
            status: .completed,
            tags: [Tag(name: "Design", colorHex: "#3525CD")],
            deadline: Calendar.current.date(byAdding: .day, value: -3, to: Date())
        ),
        TodoTask(
            title: "Add Firebase integration",
            description: "Set up FirebaseAuth and Firestore for remote sync.",
            priority: .high,
            status: .overdue,
            tags: [Tag(name: "Backend", colorHex: "#FF6B35"), Tag(name: "Firebase", colorHex: "#F59E0B")],
            deadline: Calendar.current.date(byAdding: .day, value: -2, to: Date())
        )
    ]
}

extension User {
    static let mockUser = User(
        id: "user-001",
        name: "Rama Narasimha",
        email: "rama@pocketdo.app",
        isPremium: false
    )
}
