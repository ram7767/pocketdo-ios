// MARK: - File: Features/Search/Views/SearchView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

// MARK: - SearchView

struct SearchView: View {
    @StateObject private var vm: SearchViewModel
    @EnvironmentObject var container: DependencyContainer

    init(vm: SearchViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ─────────────────────────────────
                headerSection
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)

                // ── Search Bar ─────────────────────────────
                searchBarSection
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)

                // ── Tag Filter Chips ───────────────────────
                if !vm.allTags.isEmpty {
                    tagChipScrollSection
                        .padding(.top, AppSpacing.sm)
                }

                // ── Results / States ───────────────────────
                Group {
                    if vm.isLoading {
                        loadingState
                    } else if vm.hasSearched && vm.results.isEmpty {
                        emptyState
                    } else if !vm.results.isEmpty {
                        resultsList
                    } else {
                        idleState
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await vm.loadTags() }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.results.count)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.isLoading)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Header
    // ─────────────────────────────────────────────────────────────

    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Search")
                    .font(AppTypography.headlineLg)
                    .foregroundStyle(Color.appOnSurface)
                Text("Find tasks by name or tag")
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(Color.appOnSurfaceVariant)
            }
            Spacer()
            if !vm.query.isEmpty || !vm.selectedTags.isEmpty {
                Button("Clear") { vm.clearAll() }
                    .font(AppTypography.labelSm.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.25), value: vm.query.isEmpty && vm.selectedTags.isEmpty)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Search Bar
    // ─────────────────────────────────────────────────────────────

    private var searchBarSection: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    vm.query.isEmpty
                        ? Color.appOnSurfaceVariant
                        : Color.appPrimary
                )

            TextField("Search tasks…", text: $vm.query)
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurface)
                .accessibilityIdentifier("searchTextField")
                .submitLabel(.search)

            if !vm.query.isEmpty {
                Button {
                    vm.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.appOnSurfaceVariant)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 14)
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .appShadow(.card)
        .animation(.spring(response: 0.25), value: vm.query.isEmpty)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Tag Chip Scroll
    // ─────────────────────────────────────────────────────────────

    private var tagChipScrollSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(vm.allTags) { tag in
                    SearchTagChip(
                        tag: tag,
                        isSelected: vm.selectedTags.contains(tag)
                    ) {
                        vm.toggleTag(tag)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xs)
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Results List
    // ─────────────────────────────────────────────────────────────

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.sm) {
                // Results count header
                HStack {
                    Text("\(vm.results.count) result\(vm.results.count == 1 ? "" : "s")")
                        .font(AppTypography.labelSm)
                        .foregroundStyle(Color.appOnSurfaceVariant)
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)

                ForEach(vm.results) { task in
                    SearchResultRow(task: task, query: vm.query)
                        .padding(.horizontal, AppSpacing.lg)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal:   .opacity
                        ))
                }
            }
            .padding(.bottom, 120) // clear glass tab bar
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - State Views
    // ─────────────────────────────────────────────────────────────

    private var idleState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(Color.appPrimary.opacity(0.35))

            VStack(spacing: 6) {
                Text("What are you looking for?")
                    .font(AppTypography.titleMd)
                    .foregroundStyle(Color.appOnSurface)
                Text("Type a task name or select a tag filter above.")
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(Color.appOnSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(Color.appOnSurfaceVariant.opacity(0.4))

            VStack(spacing: 6) {
                Text("No tasks found")
                    .font(AppTypography.titleMd)
                    .foregroundStyle(Color.appOnSurface)
                Text("Try a different keyword or adjust the tag filters.")
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(Color.appOnSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

            Button("Clear filters") { vm.clearAll() }
                .font(AppTypography.bodyMd.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(Color.appPrimary.opacity(0.08), in: Capsule())
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private var loadingState: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(Color.appPrimary)
                .scaleEffect(1.3)
            Text("Searching…")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SearchTagChip

private struct SearchTagChip: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(hex: tag.colorHex))
                    .frame(width: 7, height: 7)
                Text(tag.name)
                    .font(AppTypography.labelSm.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(chipBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.appSecondary.opacity(0.4) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
        .accessibilityLabel("\(tag.name) filter\(isSelected ? ", selected" : "")")
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            Color.appSecondary.opacity(0.15)
        } else {
            Color.appSurface
        }
    }
}

// MARK: - SearchResultRow

private struct SearchResultRow: View {
    let task: TodoTask
    let query: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Title with highlighted match
            highlightedTitle

            if !task.description.isEmpty {
                Text(task.description)
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(
                        task.isCompleted
                            ? Color.appOnSurfaceVariant.opacity(0.4)
                            : Color.appOnSurfaceVariant
                    )
                    .lineLimit(2)
            }

            // Tags + meta row
            HStack(spacing: AppSpacing.xs) {
                // Priority badge
                Label(task.priority.rawValue, systemImage: task.priority.icon)
                    .font(AppTypography.labelSm)
                    .foregroundStyle(priorityColor(task.priority))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor(task.priority).opacity(0.10), in: Capsule())

                Spacer()

                // Inline tags (max 3)
                HStack(spacing: 4) {
                    ForEach(task.tags.prefix(3)) { tag in
                        Circle()
                            .fill(Color(hex: tag.colorHex))
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle().strokeBorder(Color.appBackground, lineWidth: 1.5)
                            )
                    }
                    if task.tags.count > 3 {
                        Text("+\(task.tags.count - 3)")
                            .font(AppTypography.labelSm)
                            .foregroundStyle(Color.appOnSurfaceVariant)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(task.isCompleted ? Color.appBackground : Color.appSurface)
        )
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .appShadow(.card)
    }

    // Highlights the matched query substring in the title
    private var highlightedTitle: some View {
        let title = task.title
        let lower = title.lowercased()
        let lowerQuery = query.lowercased()

        if !lowerQuery.isEmpty, let range = lower.range(of: lowerQuery) {
            let nsRange = NSRange(range, in: title)
            let fullNS  = NSRange(title.startIndex..., in: title)

            var parts: [(String, Bool)] = []
            if nsRange.location > 0 {
                parts.append((String(title[title.startIndex..<range.lowerBound]), false))
            }
            parts.append((String(title[range]), true))
            if nsRange.upperBound < fullNS.length {
                parts.append((String(title[range.upperBound...]), false))
            }

            return AnyView(
                HStack(spacing: 0) {
                    ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                        Text(part.0)
                            .font(AppTypography.titleMd)
                            .foregroundStyle(
                                part.1
                                    ? Color.appPrimary
                                    : (task.isCompleted ? Color.appOnSurfaceVariant.opacity(0.4) : Color.appOnSurface)
                            )
                            .strikethrough(task.isCompleted)
                    }
                }
            )
        } else {
            return AnyView(
                Text(title)
                    .font(AppTypography.titleMd)
                    .foregroundStyle(task.isCompleted ? Color.appOnSurfaceVariant.opacity(0.4) : Color.appOnSurface)
                    .strikethrough(task.isCompleted)
            )
        }
    }

    private func priorityColor(_ p: Priority) -> Color {
        switch p {
        case .high:   return Color(hex: "#EF4444")
        case .medium: return Color(hex: "#F59E0B")
        case .low:    return Color.appSecondary
        }
    }
}

// MARK: - Color(hex:) Extension (local convenience)

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
