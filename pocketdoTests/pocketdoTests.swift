// MARK: - File: pocketdoTests/pocketdoTests.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//
//  Unit-test suite for PocketDo use-cases and the in-memory data source.
//  Uses MockTaskRepository and MockTagRepository — no CoreData, no network.

import XCTest
@testable import pocketdo

// ═══════════════════════════════════════════════════════════
// MARK: - Mock Repositories
// ═══════════════════════════════════════════════════════════

// MARK: MockTaskRepository

final class MockTaskRepository: TaskRepository {
    var tasks: [TodoTask] = []
    var shouldThrow = false

    func fetchAll() async throws -> [TodoTask] {
        if shouldThrow { throw AppError.fetchFailed }
        return tasks
    }
    func fetchPending() async throws -> [TodoTask] {
        tasks.filter { $0.status != .completed }
    }
    func fetchCompleted() async throws -> [TodoTask] {
        tasks.filter { $0.status == .completed }
    }
    func fetchByTag(_ tag: Tag) async throws -> [TodoTask] {
        tasks.filter { $0.tags.contains(tag) }
    }
    func search(query: String, tagIDs: [String]) async throws -> [TodoTask] {
        if shouldThrow { throw AppError.fetchFailed }
        var results = tasks
        if !query.isEmpty {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }
        if !tagIDs.isEmpty {
            results = results.filter { task in task.tags.contains { tagIDs.contains($0.id) } }
        }
        return results
    }
    func add(_ task: TodoTask) async throws {
        if shouldThrow { throw AppError.saveFailed }
        tasks.append(task)
    }
    func update(_ task: TodoTask) async throws {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else {
            throw AppError.fetchFailed
        }
        tasks[idx] = task
    }
    func delete(id: String) async throws {
        guard tasks.contains(where: { $0.id == id }) else { throw AppError.deleteFailed }
        tasks.removeAll { $0.id == id }
    }
    func markCompleted(id: String) async throws {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { throw AppError.fetchFailed }
        var t = tasks[idx]
        t = TodoTask(id: t.id, title: t.title, description: t.description,
                     priority: t.priority, status: .completed,
                     tags: t.tags, deadline: t.deadline, attachments: t.attachments)
        tasks[idx] = t
    }
    func syncTasks() async throws {}
    func unsyncedCount() async throws -> Int { tasks.filter { !$0.isSynced }.count }
}

// MARK: MockTagRepository

final class MockTagRepository: TagRepository {
    var tags: [Tag] = []
    var shouldThrow = false

    func fetchAll() async throws -> [Tag] {
        if shouldThrow { throw AppError.fetchFailed }
        return tags
    }
    func add(_ tag: Tag) async throws {
        if shouldThrow { throw AppError.saveFailed }
        tags.append(tag)
    }
    func delete(id: String) async throws {
        guard tags.contains(where: { $0.id == id }) else { throw AppError.deleteFailed }
        tags.removeAll { $0.id == id }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - FetchTasksUseCaseTests
// ═══════════════════════════════════════════════════════════

final class FetchTasksUseCaseTests: XCTestCase {
    var repo: MockTaskRepository!
    var sut: FetchTasksUseCase!

    override func setUp() {
        super.setUp()
        repo = MockTaskRepository()
        sut  = FetchTasksUseCase(repository: repo)
    }

    func testFetchAll_returnsAllTasks() async throws {
        repo.tasks = [
            TodoTask(title: "Alpha"),
            TodoTask(title: "Beta", status: .completed)
        ]
        let result = try await sut.execute()
        XCTAssertEqual(result.count, 2, "fetchAll should return both tasks")
    }

    func testFetchPending_excludesCompleted() async throws {
        repo.tasks = [
            TodoTask(title: "Pending Task"),
            TodoTask(title: "Done", status: .completed)
        ]
        let result = try await sut.executePending()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Pending Task")
    }

    func testFetchCompleted_onlyCompleted() async throws {
        repo.tasks = [
            TodoTask(title: "Not done"),
            TodoTask(title: "Done", status: .completed)
        ]
        let result = try await sut.executeCompleted()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Done")
    }

    func testFetchUpcoming_withinDays() async throws {
        let soon = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        let far  = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        repo.tasks = [
            TodoTask(title: "Soon",   deadline: soon),
            TodoTask(title: "Far",    deadline: far),
            TodoTask(title: "No due", deadline: nil)
        ]
        let result = try await sut.executeUpcoming(days: 7)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Soon")
    }

    func testFetchAll_throwsOnError() async {
        repo.shouldThrow = true
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - AddTaskUseCaseTests
// ═══════════════════════════════════════════════════════════

final class AddTaskUseCaseTests: XCTestCase {
    var repo: MockTaskRepository!
    var sut: AddTaskUseCase!

    override func setUp() {
        super.setUp()
        repo = MockTaskRepository()
        sut  = AddTaskUseCase(repository: repo)
    }

    func testAddTask_validTitle_insertsTask() async throws {
        let task = try await sut.execute(title: "Buy groceries", priority: .high)
        XCTAssertEqual(repo.tasks.count, 1)
        XCTAssertEqual(task.title, "Buy groceries")
        XCTAssertEqual(task.priority, .high)
    }

    func testAddTask_emptyTitle_throws() async {
        do {
            _ = try await sut.execute(title: "   ")
            XCTFail("Expected AppError for empty title")
        } catch let err as AppError {
            if case .unknown(let msg) = err {
                XCTAssertTrue(msg.contains("empty"), "Error should mention empty title")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testAddTask_withTags_preservesTags() async throws {
        let tag = Tag(name: "Work", colorHex: "#3525CD")
        let task = try await sut.execute(title: "Write report", tags: [tag])
        XCTAssertEqual(task.tags.count, 1)
        XCTAssertEqual(task.tags.first?.name, "Work")
    }

    func testAddTask_titleIsTrimmed() async throws {
        let task = try await sut.execute(title: "  Trimmed Title  ")
        XCTAssertEqual(task.title, "Trimmed Title")
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - UpdateTaskUseCaseTests
// ═══════════════════════════════════════════════════════════

final class UpdateTaskUseCaseTests: XCTestCase {
    var repo: MockTaskRepository!
    var sut: UpdateTaskUseCase!

    override func setUp() {
        super.setUp()
        repo = MockTaskRepository()
        sut  = UpdateTaskUseCase(repository: repo)
        repo.tasks = [TodoTask(title: "Original")]
    }

    func testUpdate_changesTitle() async throws {
        var task = repo.tasks[0]
        task = TodoTask(id: task.id, title: "Updated", description: task.description,
                        priority: task.priority, status: task.status,
                        tags: task.tags, deadline: task.deadline, attachments: task.attachments)
        _ = try await sut.execute(task)
        XCTAssertEqual(repo.tasks.first?.title, "Updated")
    }

    func testUpdate_emptyTitle_throws() async {
        var task = repo.tasks[0]
        task = TodoTask(id: task.id, title: "  ", description: "", priority: .low,
                        status: .pending, tags: [], deadline: nil, attachments: [])
        do {
            _ = try await sut.execute(task)
            XCTFail("Expected AppError")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testMarkCompleted_setsStatusCompleted() async throws {
        let id = repo.tasks[0].id
        try await sut.markCompleted(id: id)
        XCTAssertEqual(repo.tasks.first?.status, .completed)
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - DeleteTaskUseCaseTests
// ═══════════════════════════════════════════════════════════

final class DeleteTaskUseCaseTests: XCTestCase {
    var repo: MockTaskRepository!
    var sut: DeleteTaskUseCase!

    override func setUp() {
        super.setUp()
        repo = MockTaskRepository()
        sut  = DeleteTaskUseCase(repository: repo)
        repo.tasks = [TodoTask(title: "To Delete")]
    }

    func testDelete_removesTask() async throws {
        let id = repo.tasks[0].id
        try await sut.execute(id: id)
        XCTAssertTrue(repo.tasks.isEmpty)
    }

    func testDelete_nonExistentID_throws() async {
        do {
            try await sut.execute(id: "non-existent-id")
            XCTFail("Expected AppError.deleteFailed")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - SearchTasksUseCaseTests
// ═══════════════════════════════════════════════════════════

final class SearchTasksUseCaseTests: XCTestCase {
    var repo: MockTaskRepository!
    var tagRepo: MockTagRepository!
    var sut: SearchTasksUseCase!
    var fetchTagsSut: FetchAllTagsUseCase!

    let tagDesign = Tag(name: "Design", colorHex: "#3525CD")
    let tagDev    = Tag(name: "Dev",    colorHex: "#006E2F")

    override func setUp() {
        super.setUp()
        repo        = MockTaskRepository()
        tagRepo     = MockTagRepository()
        sut         = SearchTasksUseCase(repository: repo)
        fetchTagsSut = FetchAllTagsUseCase(repository: tagRepo)

        repo.tasks = [
            TodoTask(title: "Design auth flow",    tags: [tagDesign]),
            TodoTask(title: "Implement dashboard", tags: [tagDev]),
            TodoTask(title: "Write unit tests",    tags: [tagDev, tagDesign]),
            TodoTask(title: "Review PR",           tags: [])
        ]
        tagRepo.tags = [tagDesign, tagDev]
    }

    func testSearch_byQuery_matchesTitle() async throws {
        let results = try await sut.execute(query: "design", tagIDs: [])
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Design auth flow")
    }

    func testSearch_byQuery_caseInsensitive() async throws {
        let results = try await sut.execute(query: "UNIT", tagIDs: [])
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Write unit tests")
    }

    func testSearch_byTag_returnsTaggedTasks() async throws {
        let results = try await sut.execute(query: "", tagIDs: [tagDev.id])
        XCTAssertEqual(results.count, 2, "Both 'Implement dashboard' and 'Write unit tests' have Dev tag")
    }

    func testSearch_combined_intersects() async throws {
        // Query matches "design" → 1 task; filtered by tagDev → intersection = 0 direct, but "Write unit tests" has both
        let results = try await sut.execute(query: "unit", tagIDs: [tagDev.id])
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Write unit tests")
    }

    func testSearch_noMatch_returnsEmpty() async throws {
        let results = try await sut.execute(query: "xyzzy", tagIDs: [])
        XCTAssertTrue(results.isEmpty)
    }

    func testSearch_emptyInputs_returnsAll() async throws {
        let results = try await sut.execute(query: "", tagIDs: [])
        XCTAssertEqual(results.count, repo.tasks.count)
    }

    func testSearch_whitespaceOnlyQuery_treatedAsEmpty() async throws {
        // SearchTasksUseCase trims whitespace before passing to repository
        let results = try await sut.execute(query: "   ", tagIDs: [])
        XCTAssertEqual(results.count, repo.tasks.count)
    }

    func testFetchAllTags_returnsTags() async throws {
        let tags = try await fetchTagsSut.execute()
        XCTAssertEqual(tags.count, 2)
    }

    func testFetchAllTags_throwsOnError() async {
        tagRepo.shouldThrow = true
        do {
            _ = try await fetchTagsSut.execute()
            XCTFail("Expected error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - DashboardStatsUseCaseTests
// ═══════════════════════════════════════════════════════════

final class DashboardStatsUseCaseTests: XCTestCase {
    var repo: MockTaskRepository!
    var sut: DashboardStatsUseCase!

    override func setUp() {
        super.setUp()
        repo = MockTaskRepository()
        sut  = DashboardStatsUseCase(repository: repo)
    }

    func testStats_totalCount() async throws {
        repo.tasks = [TodoTask(title: "A"), TodoTask(title: "B")]
        let stats = try await sut.execute()
        XCTAssertEqual(stats.total, 2)
    }

    func testStats_completionRate() async throws {
        repo.tasks = [
            TodoTask(title: "A", status: .completed),
            TodoTask(title: "B", status: .pending),
            TodoTask(title: "C", status: .pending)
        ]
        let stats = try await sut.execute()
        XCTAssertEqual(stats.completed, 1)
        XCTAssertEqual(stats.completionRate, 1.0 / 3.0, accuracy: 0.001)
    }

    func testStats_overdueCount() async throws {
        let past = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let future = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        repo.tasks = [
            TodoTask(title: "Overdue", status: .pending, deadline: past),
            TodoTask(title: "Future",  status: .pending, deadline: future)
        ]
        let stats = try await sut.execute()
        XCTAssertEqual(stats.overdue, 1)
    }

    func testStats_emptyTasks_zeroRate() async throws {
        repo.tasks = []
        let stats = try await sut.execute()
        XCTAssertEqual(stats.completionRate, 0.0)
        XCTAssertEqual(stats.total, 0)
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - TagUseCaseTests
// ═══════════════════════════════════════════════════════════

final class TagUseCaseTests: XCTestCase {
    var repo: MockTagRepository!
    var addSut: AddTagUseCase!
    var deleteSut: DeleteTagUseCase!

    override func setUp() {
        super.setUp()
        repo      = MockTagRepository()
        addSut    = AddTagUseCase(repository: repo)
        deleteSut = DeleteTagUseCase(repository: repo)
    }

    func testAddTag_validName_createsTag() async throws {
        let tag = try await addSut.execute(name: "Work", colorHex: "#3525CD")
        XCTAssertEqual(repo.tags.count, 1)
        XCTAssertEqual(tag.name, "Work")
        XCTAssertEqual(tag.colorHex, "#3525CD")
    }

    func testAddTag_emptyName_throws() async {
        do {
            _ = try await addSut.execute(name: "  ")
            XCTFail("Expected AppError")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testDeleteTag_removesTag() async throws {
        repo.tags = [Tag(id: "t1", name: "Old", colorHex: "#000")]
        try await deleteSut.execute(id: "t1")
        XCTAssertTrue(repo.tags.isEmpty)
    }

    func testDeleteTag_nonExistent_throws() async {
        do {
            try await deleteSut.execute(id: "ghost")
            XCTFail("Expected AppError.deleteFailed")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
