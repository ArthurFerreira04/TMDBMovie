//
//  AppConfig.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

enum TMDBImageSize: String {
    case w185 = "w185"
    case w342 = "w342"
    case w500 = "w500"
    case w780 = "w780"
    case w1280 = "w1280"
    case original = "original"
}

enum TMDBImageContext {
    case splashBackdrop
    case heroBackdrop
    case posterGrid
    case posterDetail
    case castProfileSmall
    case castProfileLarge

    var size: TMDBImageSize {
        switch self {
        case .splashBackdrop: return .w1280
        case .heroBackdrop: return .w1280
        case .posterGrid: return .w500
        case .posterDetail: return .w780
        case .castProfileSmall: return .w185
        case .castProfileLarge: return .w342
        }
    }
}

enum AppConfig {
    static let tmdbBaseURL = URL(string: "https://api.themoviedb.org/3")!
    static let tmdbImageRootURL = URL(string: "https://image.tmdb.org/t/p")!

    static func tmdbImageURL(path: String, context: TMDBImageContext) -> URL? {
        tmdbImageURL(path: path, size: context.size)
    }

    static func tmdbImageURL(path: String, size: TMDBImageSize) -> URL? {
        let normalized = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return tmdbImageRootURL
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(normalized)
    }

    static var tmdbBearerToken: String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "TMDB_BEARER_TOKEN") as? String,
            !value.isEmpty,
            !value.contains("$(")
        else {
            assertionFailure("Missing TMDB_BEARER_TOKEN")
            return ""
        }
        return value
    }

    static var tmdbAPIKey: String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
            !value.isEmpty,
            !value.contains("$(")
        else {
            assertionFailure("Missing TMDB_API_KEY")
            return ""
        }
        return value
    }
}
