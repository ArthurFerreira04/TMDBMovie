//
//  TMDBDTOs.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

struct TMDBPagedResponseDTO<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
}

struct TMDBMovieDTO: Decodable {
    let id: Int
    let title: String?
    let posterPath: String?
    let backdropPath: String?
}

struct TMDBTVDTO: Decodable {
    let id: Int
    let name: String?
    let posterPath: String?
    let backdropPath: String?
}

struct TMDBGenre: Decodable, Equatable, Hashable {
    let id: Int
    let name: String
}

struct TMDBGenreResponse: Decodable {
    let genres: [TMDBGenre]
}

// Description

struct TMDBMovieDetailDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let genres: [TMDBGenre]
    let backdropPath: String?
    let credits: TMDBCreditsResponseDTO?
    let videos: TMDBVideosResponseDTO?
    let recommendations: TMDBPagedResponseDTO<TMDBMovieDTO>?
}

struct TMDBTVDetailDTO: Decodable {
    let id: Int
    let name: String
    let overview: String
    let firstAirDate: String?
    let episodeRunTime: [Int]
    let voteAverage: Double
    let genres: [TMDBGenre]
    let backdropPath: String?
    let credits: TMDBCreditsResponseDTO?
    let videos: TMDBVideosResponseDTO?
    let recommendations: TMDBPagedResponseDTO<TMDBTVDTO>?
}

struct TMDBWatchProvidersResponseDTO: Decodable {
    let id: Int
    let results: [String: TMDBWatchRegionDTO]
}

struct TMDBWatchRegionDTO: Decodable {
    let link: String?
    let flatrate: [TMDBProviderDTO]?
    let rent: [TMDBProviderDTO]?
    let buy: [TMDBProviderDTO]?
}

struct TMDBProviderDTO: Decodable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
}

struct TMDBCreditsResponseDTO: Decodable {
    let cast: [TMDBCastDTO]
}

struct TMDBCastDTO: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
}

struct TMDBRecommendationMovieDTO: Decodable {
    let id: Int
    let title: String?
    let posterPath: String?
}

struct TMDBRecommendationTVDTO: Decodable {
    let id: Int
    let name: String?
    let posterPath: String?
}

struct TMDBVideosResponseDTO: Decodable {
    let results: [TMDBVideoDTO]
}

struct TMDBVideoDTO: Decodable {
    let key: String
    let site: String
    let type: String
}
