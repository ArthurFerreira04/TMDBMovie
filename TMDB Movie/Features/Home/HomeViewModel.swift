//
//  HomeViewModel.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

@MainActor
final class HomeViewModel {

    enum Catalog: Equatable {
        case movie
        case tv
    }

    enum Status: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    struct ViewState: Equatable {
        var status: Status
        var catalog: Catalog
        var genres: [TMDBGenre]
        var sections: [HomeSection]
        var canLoadMoreSearch: Bool
        var isLoadingMoreSearch: Bool

        static let idle = ViewState(
            status: .idle,
            catalog: .movie,
            genres: [],
            sections: [],
            canLoadMoreSearch: false,
            isLoadingMoreSearch: false
        )
    }

    var onStateChange: ((ViewState) -> Void)?

    private let service: TMDBServiceProtocol
    private var task: Task<Void, Never>?
    private(set) var state: ViewState = .idle

    private var selectedGenre: TMDBGenre?
    private var searchQuery: String?
    private var searchPage = 1
    private var searchTotalPages = 1
    private var searchTotalResults = 0

    init(service: TMDBServiceProtocol) {
        self.service = service
    }

    func loadInitial() {
        selectedGenre = nil
        searchQuery = nil
        resetSearchPagination()
        loadCatalogContent(genre: nil, isGenreFilter: false)
    }

    func selectCatalog(_ catalog: Catalog) {
        guard state.catalog != catalog else { return }
        selectedGenre = nil
        searchQuery = nil
        resetSearchPagination()
        publish(status: .loading, catalog: catalog, sections: placeholderSections())
        loadCatalogContent(genre: nil, isGenreFilter: false)
    }

    func selectGenre(index: Int) {
        task?.cancel()
        resetSearchPagination()

        if index == 0 {
            selectedGenre = nil
            loadCatalogContent(genre: nil, isGenreFilter: false)
            return
        }

        let idx = index - 1
        guard state.genres.indices.contains(idx) else { return }
        selectedGenre = state.genres[idx]
        let genre = state.genres[idx]

        publish(status: .loading, sections: placeholderSections(genre: genre))

        loadCatalogContent(genre: genre, isGenreFilter: true)
    }

    func search(query: String) {
        task?.cancel()
        resetSearchPagination()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchQuery = nil
            if let selectedGenre, let idx = state.genres.firstIndex(of: selectedGenre) {
                selectGenre(index: idx + 1)
            } else {
                loadInitial()
            }
            return
        }

        searchQuery = trimmed
        publish(status: .loading, sections: [.init(type: .search(query: trimmed, totalResults: nil), items: [])])

        task = Task { [weak self] in
            await self?.fetchSearchPage(query: trimmed, page: 1, append: false)
        }
    }

    func loadMoreSearchIfNeeded() {
        guard
            let query = searchQuery,
            searchPage < searchTotalPages,
            state.status == .loaded,
            !state.isLoadingMoreSearch
        else { return }

        publish(isLoadingMoreSearch: true)
        task = Task { [weak self] in
            await self?.fetchSearchPage(query: query, page: (self?.searchPage ?? 0) + 1, append: true)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    private func loadCatalogContent(genre: TMDBGenre?, isGenreFilter: Bool) {
        task?.cancel()
        publish(status: .loading, sections: placeholderSections(genre: genre))

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let catalog = self.state.catalog
                let payload = try await self.fetchCatalogPayload(catalog: catalog, genre: genre)
                if Task.isCancelled { return }

                let status: Status = payload.sections.allSatisfy { $0.items.isEmpty } ? .empty : .loaded
                self.publish(
                    status: status,
                    genres: payload.genres,
                    sections: payload.sections,
                    canLoadMoreSearch: false
                )
            } catch {
                if Task.isCancelled { return }
                self.publish(status: .error(error.userMessage))
            }
        }
    }

    private struct CatalogPayload {
        let genres: [TMDBGenre]
        let sections: [HomeSection]
    }

    private func fetchCatalogPayload(catalog: Catalog, genre: TMDBGenre?) async throws -> CatalogPayload {
        switch catalog {
        case .movie:
            async let genres = service.movieGenres()
            async let trending = service.trendingMoviesWeek(page: 1)
            async let popular = service.popularMovies(page: 1)
            let (g, t, p) = try await (genres, trending, popular)

            var sections: [HomeSection] = [
                .init(type: .trendingWeek, items: Array(t.prefix(10)).map { mapItem($0, catalog: .movie) }),
                .init(type: .popular, items: Array(p.prefix(12)).map { mapItem($0, catalog: .movie) })
            ]
            if let genre {
                let discovered = try await service.discoverMovies(genreId: genre.id, page: 1)
                sections.append(.init(
                    type: .genre(id: genre.id, name: genre.name),
                    items: Array(discovered.prefix(12)).map { mapItem($0, catalog: .movie) }
                ))
            }
            return CatalogPayload(genres: g, sections: sections)

        case .tv:
            async let genres = service.tvGenres()
            async let trending = service.trendingTVWeek(page: 1)
            async let popular = service.popularTV(page: 1)
            let (g, t, p) = try await (genres, trending, popular)

            var sections: [HomeSection] = [
                .init(type: .trendingWeek, items: Array(t.prefix(10)).map { mapItem($0, catalog: .tv) }),
                .init(type: .popular, items: Array(p.prefix(12)).map { mapItem($0, catalog: .tv) })
            ]
            if let genre {
                let discovered = try await service.discoverTV(genreId: genre.id, page: 1)
                sections.append(.init(
                    type: .genre(id: genre.id, name: genre.name),
                    items: Array(discovered.prefix(12)).map { mapItem($0, catalog: .tv) }
                ))
            }
            return CatalogPayload(genres: g, sections: sections)
        }
    }

    private func fetchSearchPage(query: String, page: Int, append: Bool) async {
        do {
            switch state.catalog {
            case .movie:
                let moviePage = try await service.searchMoviesPage(query: query, page: page)
                if Task.isCancelled { return }
                searchPage = moviePage.page
                searchTotalPages = moviePage.totalPages
                searchTotalResults = moviePage.totalResults
                let items = moviePage.results.map { mapItem($0, catalog: .movie) }
                applySearchResults(query: query, items: items, append: append)

            case .tv:
                let tvPage = try await service.searchTVPage(query: query, page: page)
                if Task.isCancelled { return }
                searchPage = tvPage.page
                searchTotalPages = tvPage.totalPages
                searchTotalResults = tvPage.totalResults
                let items = tvPage.results.map { mapItem($0, catalog: .tv) }
                applySearchResults(query: query, items: items, append: append)
            }
        } catch {
            if Task.isCancelled { return }
            if append {
                publish(isLoadingMoreSearch: false)
            } else {
                publish(status: .error(error.userMessage))
            }
        }
    }

    private func applySearchResults(query: String, items: [PosterItem], append: Bool) {
        let merged: [PosterItem]
        if append, let current = state.sections.first?.items {
            merged = current + items
        } else {
            merged = items
        }

        let section = HomeSection(
            type: .search(query: query, totalResults: searchTotalResults),
            items: merged
        )
        let status: Status = merged.isEmpty ? .empty : .loaded
        publish(
            status: status,
            sections: [section],
            canLoadMoreSearch: searchPage < searchTotalPages,
            isLoadingMoreSearch: false
        )
    }

    private func placeholderSections(genre: TMDBGenre? = nil) -> [HomeSection] {
        var sections: [HomeSection] = [
            .init(type: .trendingWeek, items: []),
            .init(type: .popular, items: [])
        ]
        if let genre {
            sections.append(.init(type: .genre(id: genre.id, name: genre.name), items: []))
        }
        return sections
    }

    private func resetSearchPagination() {
        searchPage = 1
        searchTotalPages = 1
        searchTotalResults = 0
    }

    private func mapItem(_ dto: TMDBMovieDTO, catalog: Catalog) -> PosterItem {
        mapItem(id: dto.id, title: dto.title ?? "", posterPath: dto.posterPath, catalog: catalog)
    }

    private func mapItem(_ dto: TMDBTVDTO, catalog: Catalog) -> PosterItem {
        mapItem(id: dto.id, title: dto.name ?? "", posterPath: dto.posterPath, catalog: catalog)
    }

    private func mapItem(id: Int, title: String, posterPath: String?, catalog: Catalog) -> PosterItem {
        let url = posterPath.flatMap { AppConfig.tmdbImageURL(path: $0, size: .w342) }
        let kind: MediaKind = catalog == .movie ? .movie : .tv
        return PosterItem(id: id, title: title, posterURL: url, mediaKind: kind)
    }

    private func publish(
        status: Status? = nil,
        catalog: Catalog? = nil,
        genres: [TMDBGenre]? = nil,
        sections: [HomeSection]? = nil,
        canLoadMoreSearch: Bool? = nil,
        isLoadingMoreSearch: Bool? = nil
    ) {
        state = ViewState(
            status: status ?? state.status,
            catalog: catalog ?? state.catalog,
            genres: genres ?? state.genres,
            sections: sections ?? state.sections,
            canLoadMoreSearch: canLoadMoreSearch ?? state.canLoadMoreSearch,
            isLoadingMoreSearch: isLoadingMoreSearch ?? state.isLoadingMoreSearch
        )
        onStateChange?(state)
    }
}
