//
//  SplashViewModel.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import Foundation

@MainActor
final class SplashViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    var onStateChange: ((State) -> Void)?
    var onBackgroundURLsChange: (([URL]) -> Void)?

    private let service: TMDBServiceProtocol
    private var task: Task<Void, Never>?

    init(service: TMDBServiceProtocol) {
        self.service = service
    }

    func load() {
        task?.cancel()
        onStateChange?(.loading)

        task = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let movies = try await self.service.trendingMoviesWeek(page: 1)
                if Task.isCancelled { return }

                let urls: [URL] = movies
                    .compactMap { $0.backdropPath }
                    .prefix(10)
                    .compactMap { AppConfig.tmdbImageURL(path: $0, context: .splashBackdrop) }

                self.onBackgroundURLsChange?(urls)
                self.onStateChange?(urls.isEmpty ? .error("Sem imagens") : .loaded)
            } catch {
                if Task.isCancelled { return }
                self.onStateChange?(.error(error.userMessage))
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
