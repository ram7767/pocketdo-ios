// MARK: - File: Features/Search/ViewModels/SearchViewModel.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

// MARK: - SearchViewModel

@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published State
    @Published var query: String = ""
    @Published var selectedTags: Set<Tag> = []
    @Published var results: [TodoTask] = []
    @Published var allTags: [Tag] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hasSearched: Bool = false

    // MARK: - Dependencies
    private let searchUseCase:   SearchTasksUseCase
    private let fetchTagsUseCase: FetchAllTagsUseCase

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(searchUseCase: SearchTasksUseCase, fetchTagsUseCase: FetchAllTagsUseCase) {
        self.searchUseCase    = searchUseCase
        self.fetchTagsUseCase = fetchTagsUseCase

        setupDebounce()
    }

    // MARK: - Setup

    private func setupDebounce() {
        // Debounce text query: 300ms after user stops typing
        Publishers.CombineLatest($query, $selectedTags)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query, tags in
                guard let self else { return }
                Task { await self.performSearch(query: query, tags: tags) }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Actions

    func loadTags() async {
        do {
            allTags = try await fetchTagsUseCase.execute()
        } catch {
            // Non-fatal: tag chips just won't show
            allTags = []
        }
    }

    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func clearAll() {
        query        = ""
        selectedTags = []
        results      = []
        hasSearched  = false
    }

    // MARK: - Private Search

    private func performSearch(query: String, tags: Set<Tag>) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        let tagIDs  = tags.map { $0.id }

        // If nothing is entered, clear results without showing "empty state"
        guard !trimmed.isEmpty || !tagIDs.isEmpty else {
            results     = []
            hasSearched = false
            return
        }

        isLoading   = true
        hasSearched = true
        do {
            results = try await searchUseCase.execute(query: trimmed, tagIDs: tagIDs)
        } catch let err as AppError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = "Search failed. Please try again."
        }
        isLoading = false
    }
}
