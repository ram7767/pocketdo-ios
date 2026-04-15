// MARK: - File: Features/Task/Views/AddEditTaskView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct AddEditTaskView: View {
    @Binding var isPresented: Bool
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
    var taskToEdit: TodoTask? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        titleSection
                        prioritySection
                        deadlineSection
                        tagsSection
                        attachmentsSection
                    }
                    .screenPadding()
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, 100)
                }

                // Sticky Save Button
                saveBar
            }
            .navigationTitle(vm.isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundStyle(Color.appOnSurfaceVariant)
                }
            }
        }
        .onAppear {
            if let task = taskToEdit {
                vm.prepareEdit(task: task)
            } else {
                vm.prepareAdd()
            }
        }
        .toast(message: $vm.toastMessage)
    }

    // MARK: - Title & Description

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Task Details")

            VStack(spacing: AppSpacing.sm) {
                AppTextField(
                    placeholder: "Task title *",
                    text: $vm.taskTitle,
                    icon: "square.and.pencil",
                    errorMessage: vm.titleError
                )

                ZStack(alignment: .topLeading) {
                    if vm.taskDescription.isEmpty {
                        Text("Description (optional)")
                            .font(AppTypography.bodyMd)
                            .foregroundStyle(Color.appOnSurfaceMuted)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.top, 14)
                    }
                    TextEditor(text: $vm.taskDescription)
                        .font(AppTypography.bodyMd)
                        .foregroundStyle(Color.appOnSurface)
                        .frame(minHeight: 80)
                        .padding(.horizontal, AppSpacing.sm)
                        .scrollContentBackground(.hidden)
                }
                .padding(.vertical, AppSpacing.xs)
                .background(Color.appSurfaceLow)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            }
            .padding(AppSpacing.md)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .appShadow(.card)
        }
    }

    // MARK: - Priority

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Priority")

            HStack(spacing: AppSpacing.sm) {
                ForEach(Priority.allCases) { priority in
                    Button {
                        withAnimation(.spring(response: 0.3)) { vm.taskPriority = priority }
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Circle()
                                .fill(priorityColor(priority))
                                .frame(width: 8, height: 8)
                            Text(priority.rawValue)
                                .font(AppTypography.titleSm)
                                .fontWeight(vm.taskPriority == priority ? .semibold : .regular)
                        }
                        .foregroundStyle(vm.taskPriority == priority ? Color.appOnPrimary : Color.appOnSurfaceVariant)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            vm.taskPriority == priority
                                ? priorityColor(priority)
                                : Color.appSurfaceVariant
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3), value: vm.taskPriority)
                }
            }
        }
    }

    private func priorityColor(_ p: Priority) -> Color {
        switch p { case .low: return .priorityLow; case .medium: return .priorityMedium; case .high: return .priorityHigh }
    }

    // MARK: - Deadline

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Deadline")

            VStack(spacing: AppSpacing.sm) {
                Toggle(isOn: $vm.hasDeadline.animation()) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(Color.appPrimary)
                        Text("Set a deadline")
                            .font(AppTypography.bodyMd)
                            .foregroundStyle(Color.appOnSurface)
                    }
                }
                .tint(Color.appPrimary)

                if vm.hasDeadline {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { vm.taskDeadline ?? Date() },
                            set: { vm.taskDeadline = $0 }
                        ),
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color.appPrimary)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(AppSpacing.md)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .appShadow(.card)
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Tags")

            VStack(spacing: AppSpacing.sm) {
                // Existing tags
                if !vm.taskTags.isEmpty {
                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(vm.taskTags) { tag in
                            TagChip(tag: tag, isSelected: true) {
                                vm.removeTag(tag)
                            }
                        }
                    }
                }

                // Add new tag
                HStack(spacing: AppSpacing.sm) {
                    AppTextField(
                        placeholder: "Add tag…",
                        text: $vm.newTagName,
                        icon: "tag"
                    )

                    // Color picker quick swatches
                    HStack(spacing: 6) {
                        ForEach(tagColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle().strokeBorder(
                                        vm.newTagColorHex == hex ? Color.appOnSurface : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                                .onTapWithHaptic { vm.newTagColorHex = hex }
                        }
                    }

                    Button {
                        withAnimation { vm.addTag() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.appPrimary)
                    }
                    .disabled(vm.newTagName.isEmpty)
                }
            }
            .padding(AppSpacing.md)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .appShadow(.card)
        }
    }

    private let tagColors = ["#3525CD", "#006E2F", "#EF4444", "#F59E0B", "#8B5CF6", "#FF6B35"]

    // MARK: - Attachments

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Attachments")

            Button {
                // TODO: Present file picker / photo picker
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimaryContainer)
                            .frame(width: 40, height: 40)
                        Image(systemName: "paperclip")
                            .foregroundStyle(Color.appPrimary)
                            .font(.system(size: 18))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add attachment")
                            .font(AppTypography.titleSm)
                            .foregroundStyle(Color.appOnSurface)
                        Text("Photos, documents, files")
                            .font(AppTypography.labelSm)
                            .foregroundStyle(Color.appOnSurfaceMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.appOnSurfaceMuted)
                        .font(.system(size: 12))
                }
                .padding(AppSpacing.md)
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
                .appShadow(.card)
            }
            .buttonStyle(.plain)

            if !vm.taskAttachments.isEmpty {
                ForEach(vm.taskAttachments) { attachment in
                    attachmentRow(attachment)
                }
            }
        }
    }

    private func attachmentRow(_ attachment: TaskAttachment) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "doc.fill")
                .foregroundStyle(Color.appPrimary)
            Text(attachment.fileName)
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurface)
                .lineLimit(1)
            Spacer()
            Button {
                vm.taskAttachments.removeAll { $0.id == attachment.id }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.appOnSurfaceMuted)
            }
        }
        .padding(AppSpacing.sm)
        .background(Color.appSurfaceLow)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    // MARK: - Save Bar

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.appSurfaceVariant)
            HStack(spacing: AppSpacing.sm) {
                PrimaryButton(
                    vm.isEditing ? "Update Task" : "Save Task",
                    icon: "checkmark",
                    isLoading: vm.isLoading
                ) {
                    Task {
                        let saved = await vm.saveTask()
                        if saved { isPresented = false }
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    AddEditTaskView(isPresented: .constant(true))
        .environmentObject(DependencyContainer())
}
