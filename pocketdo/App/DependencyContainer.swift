// MARK: - File: App/DependencyContainer.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

// MARK: - DependencyContainer

@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Services (stateful, published)
    let authService:         AuthService
    let syncService:         SyncService
    let subscriptionService: SubscriptionService

    // MARK: - Data Sources
    private let coreDataSource: CoreDataTaskDataSource  // conforms to both LocalTaskDataSource & LocalTagDataSource

    // MARK: - Repositories
    let taskRepository: TaskRepository
    let tagRepository:  TagRepository
    let authRepository: AuthRepository

    // MARK: - Init

    init() {
        // Single CoreData source (shared NSManagedObjectContext from shared container)
        let ds = CoreDataTaskDataSource(context: PersistenceController.shared.viewContext)
        self.coreDataSource = ds

        // Repositories
        let taskRepo = TaskRepositoryImpl(local: ds, remote: FirebaseTaskDataSource())
        let tagRepo  = TagRepositoryImpl(local: ds)
        let authRepo = AuthRepositoryImpl()

        self.taskRepository = taskRepo
        self.tagRepository  = tagRepo
        self.authRepository = authRepo

        // Services
        self.authService         = AuthService(repository: authRepo)
        self.syncService         = SyncService(repository: taskRepo)
        self.subscriptionService = SubscriptionService()
    }

    // MARK: - ViewModel Factories

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            loginUseCase:  LoginUseCase(repository: authRepository),
            signupUseCase: SignupUseCase(repository: authRepository),
            guestUseCase:  GuestLoginUseCase(repository: authRepository),
            logoutUseCase: LogoutUseCase(repository: authRepository),
            authService:   authService
        )
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            fetchTasksUseCase: FetchTasksUseCase(repository: taskRepository),
            statsUseCase:      DashboardStatsUseCase(repository: taskRepository)
        )
    }

    func makeTaskViewModel() -> TaskViewModel {
        TaskViewModel(
            fetchUseCase:  FetchTasksUseCase(repository: taskRepository),
            addUseCase:    AddTaskUseCase(repository: taskRepository),
            updateUseCase: UpdateTaskUseCase(repository: taskRepository),
            deleteUseCase: DeleteTaskUseCase(repository: taskRepository)
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            searchUseCase:    SearchTasksUseCase(repository: taskRepository),
            fetchTagsUseCase: FetchAllTagsUseCase(repository: tagRepository)
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            authService:   authService,
            syncService:   syncService,
            logoutUseCase: LogoutUseCase(repository: authRepository)
        )
    }

    func makePremiumViewModel() -> PremiumViewModel {
        PremiumViewModel(subscriptionService: subscriptionService)
    }
}
