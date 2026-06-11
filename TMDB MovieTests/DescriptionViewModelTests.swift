import XCTest
@testable import TMDB_Movie

final class DescriptionViewModelTests: XCTestCase {

    @MainActor
    func testLoadMoviePublishesLoadedState() {
        let service = TMDBServiceMock()
        let favorites = FavoritesStore(defaults: UserDefaults(suiteName: "DescriptionViewModelTests")!)
        let viewModel = DescriptionViewModel(
            service: service,
            favoritesStore: favorites,
            mediaId: 42,
            mediaKind: .movie
        )

        let expectation = expectation(description: "loaded")
        viewModel.onStateChange = { state in
            if case .loaded(let output) = state {
                XCTAssertEqual(output.viewModel.summary.title, "Filme Teste")
                XCTAssertEqual(output.trailerKey, "abc")
                expectation.fulfill()
            }
        }

        viewModel.load()
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoadPublishesErrorWhenServiceFails() {
        let service = TMDBServiceMock()
        service.movieDetailError = APIError.httpStatus(404, nil)
        let favorites = FavoritesStore(defaults: UserDefaults(suiteName: "DescriptionViewModelTests.error")!)
        let viewModel = DescriptionViewModel(
            service: service,
            favoritesStore: favorites,
            mediaId: 1,
            mediaKind: .movie
        )

        let expectation = expectation(description: "error")
        viewModel.onStateChange = { state in
            if case .error(let message) = state {
                XCTAssertEqual(message, "Conteudo nao encontrado.")
                expectation.fulfill()
            }
        }

        viewModel.load()
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testToggleFavoriteUpdatesLoadedState() {
        let service = TMDBServiceMock()
        let defaults = UserDefaults(suiteName: "DescriptionViewModelTests.fav")!
        defaults.removePersistentDomain(forName: "DescriptionViewModelTests.fav")
        let favorites = FavoritesStore(defaults: defaults)
        let viewModel = DescriptionViewModel(
            service: service,
            favoritesStore: favorites,
            mediaId: 7,
            mediaKind: .movie
        )

        let loaded = expectation(description: "loaded")
        let favorited = expectation(description: "favorited")

        viewModel.onStateChange = { state in
            switch state {
            case .loaded(let output):
                if output.viewModel.header.isFavorite {
                    favorited.fulfill()
                } else {
                    loaded.fulfill()
                }
            default:
                break
            }
        }

        viewModel.load()
        wait(for: [loaded], timeout: 1.0)
        viewModel.toggleFavorite()
        wait(for: [favorited], timeout: 1.0)
        XCTAssertTrue(favorites.contains(id: 7, mediaKind: .movie))
    }

    @MainActor
    func testLoadTVPublishesLoadedState() {
        let service = TMDBServiceMock()
        let favorites = FavoritesStore(defaults: UserDefaults(suiteName: "DescriptionViewModelTests.tv")!)
        let viewModel = DescriptionViewModel(
            service: service,
            favoritesStore: favorites,
            mediaId: 99,
            mediaKind: .tv
        )

        let expectation = expectation(description: "tv loaded")
        viewModel.onStateChange = { state in
            if case .loaded(let output) = state {
                XCTAssertEqual(output.viewModel.summary.title, "Série Teste")
                XCTAssertEqual(output.viewModel.summary.ratingPercent, 75)
                XCTAssertEqual(output.viewModel.categories.chips, ["Drama"])
                XCTAssertNil(output.trailerKey)
                expectation.fulfill()
            }
        }

        viewModel.load()
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoadMovieIncludesBRWatchProviders() {
        let service = TMDBServiceMock()
        service.movieWatchProvidersResult = [
            .init(id: 8, name: "Netflix", logoURL: nil)
        ]
        let favorites = FavoritesStore(defaults: UserDefaults(suiteName: "DescriptionViewModelTests.providers")!)
        let viewModel = DescriptionViewModel(
            service: service,
            favoritesStore: favorites,
            mediaId: 42,
            mediaKind: .movie
        )

        let expectation = expectation(description: "providers loaded")
        viewModel.onStateChange = { state in
            if case .loaded(let output) = state {
                XCTAssertEqual(output.viewModel.watchProviders.title, "Onde assistir")
                XCTAssertEqual(output.viewModel.watchProviders.providers.map(\.name), ["Netflix"])
                expectation.fulfill()
            }
        }

        viewModel.load()
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testToggleFavoriteTVUpdatesLoadedState() {
        let service = TMDBServiceMock()
        let defaults = UserDefaults(suiteName: "DescriptionViewModelTests.tvFav")!
        defaults.removePersistentDomain(forName: "DescriptionViewModelTests.tvFav")
        let favorites = FavoritesStore(defaults: defaults)
        let viewModel = DescriptionViewModel(
            service: service,
            favoritesStore: favorites,
            mediaId: 12,
            mediaKind: .tv
        )

        let loaded = expectation(description: "tv loaded")
        let favorited = expectation(description: "tv favorited")

        viewModel.onStateChange = { state in
            switch state {
            case .loaded(let output):
                if output.viewModel.header.isFavorite {
                    favorited.fulfill()
                } else {
                    loaded.fulfill()
                }
            default:
                break
            }
        }

        viewModel.load()
        wait(for: [loaded], timeout: 1.0)
        viewModel.toggleFavorite()
        wait(for: [favorited], timeout: 1.0)
        XCTAssertTrue(favorites.contains(id: 12, mediaKind: .tv))
    }

    // MARK: - Overview fallback

    @MainActor
    func testLoadMovieUsesOverviewFallbackWhenEmpty() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(overview: "")
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.emptyOverview.movie")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.overview, "Sem descrição disponível.")
    }

    @MainActor
    func testLoadTVUsesOverviewFallbackWhenEmpty() {
        let service = TMDBServiceMock()
        service.tvDetailResult = makeTVDetail(overview: "")
        let viewModel = makeTVViewModel(service: service, suiteName: "DescriptionViewModelTests.emptyOverview.tv")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.overview, "Sem descrição disponível.")
    }

    // MARK: - Runtime formatting

    @MainActor
    func testLoadMovieFormatsRuntime120AsTwoHours() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(runtime: 120, releaseDate: nil)
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.runtime120")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.summary.meta, "2h 0m")
    }

    @MainActor
    func testLoadMovieFormatsRuntime45AsMinutesOnly() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(runtime: 45, releaseDate: nil)
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.runtime45")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.summary.meta, "45m")
    }

    @MainActor
    func testLoadMovieOmitsRuntimeFromMetaWhenNil() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(runtime: nil, releaseDate: "2024")
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.runtimeNil")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.summary.meta, "2024")
    }

    @MainActor
    func testLoadMovieFormatsRuntimeZeroAsZeroMinutes() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(runtime: 0, releaseDate: nil)
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.runtimeZero")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.summary.meta, "0m")
    }

    // MARK: - Recommendations limit

    @MainActor
    func testLoadMovieLimitsRecommendationsToTwelve() {
        let service = TMDBServiceMock()
        let recommendations = (1...15).map {
            TMDBMovieDTO(id: $0, title: "Rec \($0)", posterPath: nil, backdropPath: nil)
        }
        service.movieDetailResult = makeMovieDetail(recommendations: recommendations)
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.recLimit.movie")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.recommendations.items.count, 12)
        XCTAssertEqual(output.viewModel.recommendations.items.map(\.id), Array(1...12))
        XCTAssertTrue(output.viewModel.recommendations.items.allSatisfy { $0.mediaKind == .movie })
    }

    @MainActor
    func testLoadTVRecommendationsUseTVMediaKind() {
        let service = TMDBServiceMock()
        let recommendations = [
            TMDBTVDTO(id: 101, name: "Série A", posterPath: nil, backdropPath: nil),
            TMDBTVDTO(id: 102, name: "Série B", posterPath: nil, backdropPath: nil)
        ]
        service.tvDetailResult = makeTVDetail(recommendations: recommendations)
        let viewModel = makeTVViewModel(service: service, suiteName: "DescriptionViewModelTests.recKind.tv")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.recommendations.items.map(\.title), ["Série A", "Série B"])
        XCTAssertTrue(output.viewModel.recommendations.items.allSatisfy { $0.mediaKind == .tv })
    }

    // MARK: - Watch providers

    @MainActor
    func testLoadMovieWithEmptyWatchProviders() {
        let service = TMDBServiceMock()
        service.movieWatchProvidersResult = []
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.emptyProviders")

        let output = loadedOutput(from: viewModel)

        XCTAssertEqual(output.viewModel.watchProviders.title, "Onde assistir")
        XCTAssertTrue(output.viewModel.watchProviders.providers.isEmpty)
    }

    // MARK: - Trailer absence

    @MainActor
    func testLoadMovieWithoutTrailerUsesUnavailableCTA() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(videos: [])
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.noTrailer.empty")

        let output = loadedOutput(from: viewModel)

        XCTAssertNil(output.trailerKey)
        XCTAssertEqual(output.viewModel.ctaTitle, "Trailer indisponível")
    }

    @MainActor
    func testLoadMovieIgnoresNonYouTubeVideosForTrailer() {
        let service = TMDBServiceMock()
        service.movieDetailResult = makeMovieDetail(videos: [
            .init(key: "vimeo-key", site: "Vimeo", type: "Trailer")
        ])
        let viewModel = makeMovieViewModel(service: service, suiteName: "DescriptionViewModelTests.noTrailer.nonYouTube")

        let output = loadedOutput(from: viewModel)

        XCTAssertNil(output.trailerKey)
        XCTAssertEqual(output.viewModel.ctaTitle, "Trailer indisponível")
    }
}

// MARK: - Test helpers

private extension DescriptionViewModelTests {

    @MainActor
    func loadedOutput(
        from viewModel: DescriptionViewModel,
        timeout: TimeInterval = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> DescriptionViewModel.Output {
        let expectation = expectation(description: "loaded")
        var captured: DescriptionViewModel.Output?
        viewModel.onStateChange = { state in
            if case .loaded(let output) = state {
                captured = output
                expectation.fulfill()
            }
        }
        viewModel.load()
        wait(for: [expectation], timeout: timeout)
        guard let captured else {
            XCTFail("Expected loaded state", file: file, line: line)
            fatalError()
        }
        return captured
    }

    @MainActor
    func makeMovieViewModel(service: TMDBServiceMock, suiteName: String) -> DescriptionViewModel {
        DescriptionViewModel(
            service: service,
            favoritesStore: FavoritesStore(defaults: UserDefaults(suiteName: suiteName)!),
            mediaId: service.movieDetailResult?.id ?? 1,
            mediaKind: .movie
        )
    }

    @MainActor
    func makeTVViewModel(service: TMDBServiceMock, suiteName: String) -> DescriptionViewModel {
        DescriptionViewModel(
            service: service,
            favoritesStore: FavoritesStore(defaults: UserDefaults(suiteName: suiteName)!),
            mediaId: service.tvDetailResult?.id ?? 1,
            mediaKind: .tv
        )
    }

    func makeMovieDetail(
        id: Int = 1,
        overview: String = "Sinopse",
        runtime: Int? = 120,
        releaseDate: String? = "2024",
        recommendations: [TMDBMovieDTO] = [],
        videos: [TMDBVideoDTO]? = [.init(key: "abc", site: "YouTube", type: "Trailer")]
    ) -> TMDBMovieDetailDTO {
        .init(
            id: id,
            title: "Filme Teste",
            overview: overview,
            releaseDate: releaseDate,
            runtime: runtime,
            voteAverage: 8.0,
            genres: [],
            backdropPath: nil,
            credits: nil,
            videos: videos.map { .init(results: $0) },
            recommendations: recommendations.isEmpty ? nil : .init(
                page: 1,
                results: recommendations,
                totalPages: 1,
                totalResults: recommendations.count
            )
        )
    }

    func makeTVDetail(
        id: Int = 1,
        overview: String = "Sinopse",
        recommendations: [TMDBTVDTO] = []
    ) -> TMDBTVDetailDTO {
        .init(
            id: id,
            name: "Série Teste",
            overview: overview,
            firstAirDate: "2024",
            episodeRunTime: [45],
            voteAverage: 7.5,
            genres: [],
            backdropPath: nil,
            credits: nil,
            videos: nil,
            recommendations: recommendations.isEmpty ? nil : .init(
                page: 1,
                results: recommendations,
                totalPages: 1,
                totalResults: recommendations.count
            )
        )
    }
}
