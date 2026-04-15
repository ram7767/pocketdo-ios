// MARK: - File: Features/Task/ViewModels/TaskViewModel.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

@MainActor
final class TaskViewModel: ObservableObject {

    // MARK: - Published State
    @Published var tasks: [TodoTask] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var toastMessage: String? = nil

    // Add/Edit form state
    @Published var editingTask: TodoTask? = nil
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var taskPriority: Priority = .medium
    @Published var taskDeadline: Date? = nil
    @Published var taskTags: [Tag] = []
    @Published var taskAttachments: [TaskAttachment] = []
    @Published var hasDeadline: Bool = false

    // Tag editing
    @Published var newTagName: String = ""
    @Published var newTagColorHex: String = "#3525CD"

    // Validation
    @Published var titleError: String? = nil

    // MARK: - Dependencies
    private let fetchUseCase:  FetchTasksUseCase
    private let addUseCase:    AddTaskUseCase
    private let updateUseCase: UpdateTaskUseCase
    private let deleteUseCase: DeleteTaskUseCase

    // MARK: - Init

    init(
        fetchUseCase: FetchTasksUseCase,
        addUseCase: AddTaskUseCase,
        updateUseCase: UpdateTaskUseCase,
        deleteUseCase: DeleteTaskUseCase
    ) {
        self.fetchUseCase  = fetchUseCase
        self.addUseCase    = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
    }

    // MARK: - Load

    func loadTasks() async {
        isLoading = true
        do {
            tasks = try await fetchUseCase.execute()
        } catch let err as AppError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = "Failed to load tasks."
        }
        isLoading = false
    }

    // MARK: - Save (Add or Edit)

    func saveTask() async -> Bool {
        titleError = nil
        guard !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            titleError = "Task title is required."
            return false
        }

        isLoading = true
        do {
            if let existing = editingTask {
                // Update path
                var updated = existing
                updated = TodoTask(
                    id: existing.id,
                    title: taskTitle,
                    description: taskDescription,
                    priority: taskPriority,
                    status: existing.status,
                    tags: taskTags,
                    deadline: hasDeadline ? taskDeadline : nil,
                    attachments: taskAttachments
                )
                _ = try await updateUseCase.execute(updated)
                toastMessage = "Task updated ✓"
            } else {
                // Add path
                _ = try await addUseCase.execute(
                    title: taskTitle,
                    description: taskDescription,
                    priority: taskPriority,
                    deadline: hasDeadline ? taskDeadline : nil,
                    tags: taskTags,
                    attachments: taskAttachments
                )
                toastMessage = "Task added ✓"
            }
            await loadTasks()
            clearForm()
            isLoading = false
            return true
        } catch let err as AppError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = "Failed to save task."
        }
        isLoading = false
        return false
    }

    // MARK: - Delete

    func deleteTask(id: String) async {
        do {
            try await deleteUseCase.execute(id: id)
            tasks.removeAll { $0.id == id }
            toastMessage = "Task deleted"
        } catch {
            errorMessage = "Failed to delete task."
        }
    }

    // MARK: - Complete

    func toggleComplete(task: TodoTask) async {
        do {
            if task.isCompleted {
                var updated = task
                updated = TodoTask(
                    id: task.id, title: task.title, description: task.description,
                    priority: task.priority, status: .pending,
                    tags: task.tags, deadline: task.deadline, attachments: task.attachments
                )
                _ = try await updateUseCase.execute(updated)
            } else {
                try await updateUseCase.markCompleted(id: task.id)
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            await loadTasks()
        } catch {
            errorMessage = "Failed to update task."
        }
    }

    // MARK: - Tag Management

    func addTag() {
        guard !newTagName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let tag = Tag(name: newTagName.trimmingCharacters(in: .whitespaces), colorHex: newTagColorHex)
        taskTags.append(tag)
        newTagName = ""
    }

    func removeTag(_ tag: Tag) {
        taskTags.removeAll { $0.id == tag.id }
    }

    // MARK: - Edit Setup

    func prepareEdit(task: TodoTask) {
        editingTask      = task
        taskTitle        = task.title
        taskDescription  = task.description
        taskPriority     = task.priority
        taskTags         = task.tags
        taskAttachments  = task.attachments
        hasDeadline      = task.deadline != nil
        taskDeadline     = task.deadline ?? Date()
    }

    func prepareAdd() {
        clearForm()
    }

    // MARK: - Helpers

    func clearForm() {
        editingTask     = nil
        taskTitle       = ""
        taskDescription = ""
        taskPriority    = .medium
        taskDeadline    = nil
        taskTags        = []
        taskAttachments = []
        hasDeadline     = false
        newTagName      = ""
        titleError      = nil
    }

    var isEditing: Bool { editingTask != nil }
}
