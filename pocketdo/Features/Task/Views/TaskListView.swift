// MARK: - File: Features/Task/Views/TaskListView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject private var vm: TaskViewModel = {
        let repo = TaskRepositoryImpl(local: InMemoryTaskDataSource(), remote: FirebaseTaskDataSource())
        return TaskViewModel(
            fetchUseCase:  FetchTasksUseCase(repository: repo),
            addUseCase:    AddTaskUseCase(repository: repo),
            updateUseCase: UpdateTaskUseCase(repository: repo),
            deleteUseCase: DeleteTaskUseCase(repository: repo)
        )
    }()

    @State private var showAddTask: Bool = false
    @State private var taskToEdit: TodoTask? = nil
    @State private var searchText: String = ""

    var filteredTasks: [TodoTask] {
        guard !searchText.isEmpty else { return vm.tasks }
        return vm.tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if vm.isLoading {
                    loadingView
                } else if filteredTasks.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle.fill",
                        title: searchText.isEmpty ? "All clear!" : "No matching tasks",
                        subtitle: searchText.isEmpty
                            ? "You have no tasks. Tap + to get started."
                            : "Try a different search term.",
                        actionTitle: searchText.isEmpty ? "Add Task" : nil,
                        action: searchText.isEmpty ? { showAddTask = true } : nil
                    )
                } else {
                    taskList
                }
            }
            .navigationTitle("All Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddTask = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search tasks…")
            .sheet(isPresented: $showAddTask, onDismiss: { Task { await vm.loadTasks() } }) {
                AddEditTaskView(isPresented: $showAddTask)
                    .environmentObject(container)
            }
            .sheet(item: $taskToEdit, onDismiss: { Task { await vm.loadTasks() } }) { task in
                AddEditTaskView(isPresented: .constant(true), taskToEdit: task)
                    .environmentObject(container)
            }
            .toast(message: $vm.toastMessage)
        }
        .task { await vm.loadTasks() }
    }

    private var taskList: some View {
        List {
            ForEach(filteredTasks) { task in
                TaskListRow(task: task) {
                    Task { await vm.toggleComplete(task: task) }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: AppSpacing.xs / 2, leading: AppSpacing.lg, bottom: AppSpacing.xs / 2, trailing: AppSpacing.lg))
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        Task { await vm.toggleComplete(task: task) }
                    } label: {
                        Label(task.isCompleted ? "Undo" : "Done",
                              systemImage: task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                    }
                    .tint(Color.appSecondary)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task { await vm.deleteTask(id: task.id) }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    Button {
                        taskToEdit = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(Color.appPrimary)
                }
            }
        }
        .listStyle(.plain)
        .background(Color.appBackground)
    }

    private var loadingView: some View {
        List {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonRow()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Task List Row (with completion toggle)

struct TaskListRow: View {
    let task: TodoTask
    let onToggle: () -> Void
    @State private var isCompleting = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Completion checkbox
            Button {
                withAnimation(.spring(response: 0.3)) { isCompleting = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isCompleting = false
                    onToggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(
                            task.isCompleted ? Color.appSecondary : Color.appOutlineVariant,
                            lineWidth: task.isCompleted ? 0 : 1.5
                        )
                        .frame(width: 26, height: 26)

                    if task.isCompleted || isCompleting {
                        Circle()
                            .fill(AppGradients.successAccent)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(isCompleting ? 1.2 : 1.0)
            .animation(.spring(response: 0.3), value: isCompleting)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppTypography.titleMd)
                    .foregroundStyle(task.isCompleted ? Color.appOnSurfaceVariant.opacity(0.5) : Color.appOnSurface)
                    .strikethrough(task.isCompleted, color: Color.appOnSurfaceMuted)
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xs) {
                    StatusBadge(status: task.computedStatus)

                    if let deadline = task.deadline {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                                .font(.system(size: 9))
                            Text(deadline.relativeDateString)
                                .font(AppTypography.labelSm)
                        }
                        .foregroundStyle(deadline.isOverdue ? Color.appError : Color.appOnSurfaceMuted)
                    }
                }
            }

            Spacer()

            PriorityBadge(priority: task.priority)
        }
        .padding(AppSpacing.md)
        .background(task.isCompleted ? Color.appSurfaceDim.opacity(0.5) : Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        .appShadow(task.isCompleted ? .card : .card)
        .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
    }
}

#Preview {
    TaskListView()
        .environmentObject(DependencyContainer())
}
