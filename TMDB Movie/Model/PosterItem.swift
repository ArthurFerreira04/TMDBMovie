//
//  PosterItem.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

struct PosterItem: Hashable {
    let id: Int
    let title: String
    let posterURL: URL?
    let mediaKind: MediaKind

    init(id: Int, title: String, posterURL: URL?, mediaKind: MediaKind = .movie) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.mediaKind = mediaKind
    }
}
