//
//  FavoritesStore.swift
//  TMDB Movie
//

import Foundation

struct FavoriteMovie: Codable, Equatable {
    let id: Int
    let title: String
    let posterURLString: String?
    let mediaKind: MediaKind

    init(id: Int, title: String, posterURLString: String?, mediaKind: MediaKind = .movie) {
        self.id = id
        self.title = title
        self.posterURLString = posterURLString
        self.mediaKind = mediaKind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        posterURLString = try container.decodeIfPresent(String.self, forKey: .posterURLString)
        mediaKind = try container.decodeIfPresent(MediaKind.self, forKey: .mediaKind) ?? .movie
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(posterURLString, forKey: .posterURLString)
        try container.encode(mediaKind, forKey: .mediaKind)
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, posterURLString, mediaKind
    }

    var asPosterItem: PosterItem {
        PosterItem(
            id: id,
            title: title,
            posterURL: posterURLString.flatMap(URL.init(string:)),
            mediaKind: mediaKind
        )
    }
}

protocol FavoritesStoreProtocol: AnyObject {
    func all() -> [FavoriteMovie]
    func contains(id: Int, mediaKind: MediaKind) -> Bool
    func add(_ movie: FavoriteMovie)
    func remove(id: Int, mediaKind: MediaKind)
    func removeAll()
}

final class FavoritesStore: FavoritesStoreProtocol {
    private enum StorageKey {
        static let favorites = "favorites.movies.v1"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func all() -> [FavoriteMovie] {
        load().sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func contains(id: Int, mediaKind: MediaKind) -> Bool {
        load().contains { $0.id == id && $0.mediaKind == mediaKind }
    }

    func add(_ movie: FavoriteMovie) {
        var items = load()
        guard !items.contains(where: { $0.id == movie.id && $0.mediaKind == movie.mediaKind }) else { return }
        items.append(movie)
        save(items)
    }

    func remove(id: Int, mediaKind: MediaKind) {
        var items = load()
        items.removeAll { $0.id == id && $0.mediaKind == mediaKind }
        save(items)
    }

    func removeAll() {
        save([])
    }

    private func load() -> [FavoriteMovie] {
        guard
            let data = defaults.data(forKey: StorageKey.favorites),
            let decoded = try? decoder.decode([FavoriteMovie].self, from: data)
        else { return [] }

        return decoded
    }

    private func save(_ items: [FavoriteMovie]) {
        guard let data = try? encoder.encode(items) else { return }
        defaults.set(data, forKey: StorageKey.favorites)
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
}

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}
