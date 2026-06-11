//
//  DescriptionViewModel.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import Foundation

@MainActor
final class DescriptionViewModel {

    enum State {
        case idle
        case loading
        case loaded(Output)
        case error(String)
    }

    struct Output {
        let viewModel: DescriptionView.ViewModel
        let backdropURL: URL?
        let trailerKey: String?
    }

    var onStateChange: ((State) -> Void)?

    private let service: TMDBServiceProtocol
    private let favoritesStore: FavoritesStoreProtocol
    private let mediaId: Int
    private let mediaKind: MediaKind
    private let seedPosterItem: PosterItem?

    private var task: Task<Void, Never>?
    private var latestOutput: Output?

    init(
        service: TMDBServiceProtocol,
        favoritesStore: FavoritesStoreProtocol,
        mediaId: Int,
        mediaKind: MediaKind,
        seedPosterItem: PosterItem? = nil
    ) {
        self.service = service
        self.favoritesStore = favoritesStore
        self.mediaId = mediaId
        self.mediaKind = mediaKind
        self.seedPosterItem = seedPosterItem
    }

    convenience init(
        service: TMDBServiceProtocol,
        favoritesStore: FavoritesStoreProtocol,
        movieId: Int,
        seedPosterItem: PosterItem? = nil
    ) {
        self.init(
            service: service,
            favoritesStore: favoritesStore,
            mediaId: movieId,
            mediaKind: .movie,
            seedPosterItem: seedPosterItem
        )
    }

    func load() {
        task?.cancel()
        onStateChange?(.loading)

        task = Task { [weak self] in
            guard let self else { return }

            do {
                let output: Output
                switch self.mediaKind {
                case .movie:
                    async let detail = self.service.movieDetailAggregated(id: self.mediaId)
                    async let providers = self.service.movieWatchProviders(id: self.mediaId, region: "BR")
                    let (movie, watch) = try await (detail, providers)
                    if Task.isCancelled { return }
                    output = self.makeOutput(content: self.detailContent(from: movie), providers: watch)

                case .tv:
                    async let detail = self.service.tvDetailAggregated(id: self.mediaId)
                    async let providers = self.service.tvWatchProviders(id: self.mediaId, region: "BR")
                    let (show, watch) = try await (detail, providers)
                    if Task.isCancelled { return }
                    output = self.makeOutput(content: self.detailContent(from: show), providers: watch)
                }

                self.latestOutput = output
                self.onStateChange?(.loaded(output))
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

    func toggleFavorite() {
        if favoritesStore.contains(id: mediaId, mediaKind: mediaKind) {
            favoritesStore.remove(id: mediaId, mediaKind: mediaKind)
            updateFavoriteStateAndEmit(false)
            return
        }

        let title = latestOutput?.viewModel.summary.title ?? seedPosterItem?.title ?? "Título"
        let posterURLString = seedPosterItem?.posterURL?.absoluteString
        favoritesStore.add(.init(
            id: mediaId,
            title: title,
            posterURLString: posterURLString,
            mediaKind: mediaKind
        ))
        updateFavoriteStateAndEmit(true)
    }

    private struct DetailContent {
        let title: String
        let overview: String
        let metaDate: String
        let metaRuntime: String
        let voteAverage: Double
        let backdropPath: String?
        let cast: [TMDBCastDTO]
        let videos: [TMDBVideoDTO]
        let genreNames: [String]
        let recommendations: [PosterItem]
    }

    private func detailContent(from detail: TMDBMovieDetailDTO) -> DetailContent {
        let recs = detail.recommendations?.results ?? []
        return DetailContent(
            title: detail.title,
            overview: detail.overview,
            metaDate: detail.releaseDate ?? "",
            metaRuntime: detail.runtime.map(formatRuntime) ?? "",
            voteAverage: detail.voteAverage,
            backdropPath: detail.backdropPath,
            cast: detail.credits?.cast ?? [],
            videos: detail.videos?.results ?? [],
            genreNames: detail.genres.map(\.name),
            recommendations: recs.prefix(12).map(mapMovie)
        )
    }

    private func detailContent(from detail: TMDBTVDetailDTO) -> DetailContent {
        let recs = detail.recommendations?.results ?? []
        return DetailContent(
            title: detail.name,
            overview: detail.overview,
            metaDate: detail.firstAirDate ?? "",
            metaRuntime: detail.episodeRunTime.first.map(formatRuntime) ?? "",
            voteAverage: detail.voteAverage,
            backdropPath: detail.backdropPath,
            cast: detail.credits?.cast ?? [],
            videos: detail.videos?.results ?? [],
            genreNames: detail.genres.map(\.name),
            recommendations: recs.prefix(12).map(mapTV)
        )
    }

    private func makeOutput(
        content: DetailContent,
        providers: [WatchProviderItem]
    ) -> Output {
        let overview = content.overview.isEmpty ? "Sem descrição disponível." : content.overview
        let meta = [content.metaDate, content.metaRuntime].filter { !$0.isEmpty }.joined(separator: "  •  ")
        let ratingPercent = Int((content.voteAverage * 10).rounded())
        let backdropURL = content.backdropPath.flatMap { AppConfig.tmdbImageURL(path: $0, context: .heroBackdrop) }
        let trailerKey = pickTrailerKey(from: content.videos)
        let isFavorite = favoritesStore.contains(id: mediaId, mediaKind: mediaKind)

        let viewModel = DescriptionView.ViewModel(
            header: .init(image: nil, isFavorite: isFavorite),
            summary: .init(ratingPercent: ratingPercent, title: content.title, meta: meta),
            overview: overview,
            ctaTitle: trailerKey == nil ? "Trailer indisponível" : "Assistir trailer",
            watchProviders: makeWatchProvidersViewModel(providers),
            cast: .init(title: "Elenco principal", items: content.cast.prefix(12).map(mapCast)),
            categories: .init(title: "Categorias", chips: content.genreNames),
            recommendations: .init(title: "Recomendações", items: content.recommendations)
        )

        return Output(viewModel: viewModel, backdropURL: backdropURL, trailerKey: trailerKey)
    }

    private func makeWatchProvidersViewModel(_ providers: [WatchProviderItem]) -> WatchProvidersSectionView.ViewModel {
        .init(title: "Onde assistir", providers: providers)
    }

    private func updateFavoriteStateAndEmit(_ isFavorite: Bool) {
        guard let output = latestOutput else { return }

        let updatedViewModel = DescriptionView.ViewModel(
            header: .init(image: output.viewModel.header.image, isFavorite: isFavorite),
            summary: output.viewModel.summary,
            overview: output.viewModel.overview,
            ctaTitle: output.viewModel.ctaTitle,
            watchProviders: output.viewModel.watchProviders,
            cast: output.viewModel.cast,
            categories: output.viewModel.categories,
            recommendations: output.viewModel.recommendations
        )

        latestOutput = Output(
            viewModel: updatedViewModel,
            backdropURL: output.backdropURL,
            trailerKey: output.trailerKey
        )
        onStateChange?(.loaded(latestOutput!))
    }

    private func mapCast(_ dto: TMDBCastDTO) -> CastItem {
        let url = dto.profilePath.flatMap { AppConfig.tmdbImageURL(path: $0, context: .castProfileLarge) }
        return CastItem(id: dto.id, name: dto.name, profileURL: url)
    }

    private func mapMovie(_ dto: TMDBMovieDTO) -> PosterItem {
        mapPosterItem(id: dto.id, title: dto.title ?? "", posterPath: dto.posterPath, mediaKind: .movie)
    }

    private func mapTV(_ dto: TMDBTVDTO) -> PosterItem {
        mapPosterItem(id: dto.id, title: dto.name ?? "", posterPath: dto.posterPath, mediaKind: .tv)
    }

    private func mapPosterItem(id: Int, title: String, posterPath: String?, mediaKind: MediaKind) -> PosterItem {
        let url = posterPath.flatMap { AppConfig.tmdbImageURL(path: $0, context: .posterGrid) }
        return PosterItem(id: id, title: title, posterURL: url, mediaKind: mediaKind)
    }

    private func pickTrailerKey(from videos: [TMDBVideoDTO]) -> String? {
        let youtube = videos.filter { $0.site.lowercased() == "youtube" }
        let trailer = youtube.first { $0.type.lowercased() == "trailer" }
        return trailer?.key ?? youtube.first?.key
    }

    private func formatRuntime(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}
