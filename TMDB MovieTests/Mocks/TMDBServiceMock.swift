import Foundation
@testable import TMDB_Movie

final class TMDBServiceMock: TMDBServiceProtocol {
    var movieGenresResult: [TMDBGenre] = []
    var tvGenresResult: [TMDBGenre] = []
    var trendingMoviesWeekResult: [TMDBMovieDTO] = []
    var trendingTVWeekResult: [TMDBTVDTO] = []
    var popularMoviesResult: [TMDBMovieDTO] = []
    var popularTVResult: [TMDBTVDTO] = []
    var searchMoviesResult: [TMDBMovieDTO] = []
    var searchTVResult: [TMDBTVDTO] = []
    var searchMoviesError: Error?
    var searchTVError: Error?
    var movieDetailResult: TMDBMovieDetailDTO?
    var movieDetailError: Error?
    var tvDetailResult: TMDBTVDetailDTO?
    var tvDetailError: Error?
    var movieWatchProvidersResult: [WatchProviderItem] = []
    var tvWatchProvidersResult: [WatchProviderItem] = []

    func popularMovies(page: Int) async throws -> [TMDBMovieDTO] { popularMoviesResult }
    func popularTV(page: Int) async throws -> [TMDBTVDTO] { popularTVResult }

    func searchMovies(query: String, page: Int) async throws -> [TMDBMovieDTO] {
        if let searchMoviesError { throw searchMoviesError }
        return searchMoviesResult
    }

    func searchTV(query: String, page: Int) async throws -> [TMDBTVDTO] {
        if let searchTVError { throw searchTVError }
        return searchTVResult
    }

    func movieGenres() async throws -> [TMDBGenre] { movieGenresResult }
    func tvGenres() async throws -> [TMDBGenre] { tvGenresResult }

    func discoverMovies(genreId: Int, page: Int) async throws -> [TMDBMovieDTO] { [] }
    func discoverTV(genreId: Int, page: Int) async throws -> [TMDBTVDTO] { [] }

    func trendingMoviesWeek(page: Int) async throws -> [TMDBMovieDTO] { trendingMoviesWeekResult }
    func trendingTVWeek(page: Int) async throws -> [TMDBTVDTO] { trendingTVWeekResult }

    func movieDetail(id: Int) async throws -> TMDBMovieDetailDTO {
        try await movieDetailAggregated(id: id)
    }

    func movieDetailAggregated(id: Int) async throws -> TMDBMovieDetailDTO {
        if let movieDetailError { throw movieDetailError }
        return movieDetailResult ?? .init(
            id: id,
            title: "Filme Teste",
            overview: "Sinopse",
            releaseDate: "2024",
            runtime: 120,
            voteAverage: 8.2,
            genres: [.init(id: 1, name: "Ação")],
            backdropPath: "/backdrop.jpg",
            credits: .init(cast: [.init(id: 1, name: "Ator", profilePath: nil)]),
            videos: .init(results: [.init(key: "abc", site: "YouTube", type: "Trailer")]),
            recommendations: .init(
                page: 1,
                results: [.init(id: 2, title: "Rec", posterPath: nil, backdropPath: nil)],
                totalPages: 1,
                totalResults: 1
            )
        )
    }

    func movieCredits(id: Int) async throws -> [TMDBCastDTO] { [] }
    func movieRecommendations(id: Int, page: Int) async throws -> [TMDBMovieDTO] { [] }
    func movieVideos(id: Int) async throws -> [TMDBVideoDTO] { [] }
    func movieWatchProviders(id: Int, region: String) async throws -> [WatchProviderItem] {
        movieWatchProvidersResult
    }

    func tvDetail(id: Int) async throws -> TMDBTVDetailDTO {
        try await tvDetailAggregated(id: id)
    }

    func tvDetailAggregated(id: Int) async throws -> TMDBTVDetailDTO {
        if let tvDetailError { throw tvDetailError }
        return tvDetailResult ?? .init(
            id: id,
            name: "Série Teste",
            overview: "Sinopse",
            firstAirDate: "2024",
            episodeRunTime: [45],
            voteAverage: 7.5,
            genres: [.init(id: 2, name: "Drama")],
            backdropPath: nil,
            credits: nil,
            videos: nil,
            recommendations: nil
        )
    }

    func tvCredits(id: Int) async throws -> [TMDBCastDTO] { [] }
    func tvRecommendations(id: Int, page: Int) async throws -> [TMDBTVDTO] { [] }
    func tvVideos(id: Int) async throws -> [TMDBVideoDTO] { [] }
    func tvWatchProviders(id: Int, region: String) async throws -> [WatchProviderItem] {
        tvWatchProvidersResult
    }

    func searchMoviesPage(query: String, page: Int) async throws -> TMDBPagedResponseDTO<TMDBMovieDTO> {
        if let searchMoviesError { throw searchMoviesError }
        return .init(
            page: page,
            results: searchMoviesResult,
            totalPages: 3,
            totalResults: searchMoviesResult.count * 3
        )
    }

    func searchTVPage(query: String, page: Int) async throws -> TMDBPagedResponseDTO<TMDBTVDTO> {
        if let searchTVError { throw searchTVError }
        return .init(
            page: page,
            results: searchTVResult,
            totalPages: 2,
            totalResults: searchTVResult.count * 2
        )
    }
}
