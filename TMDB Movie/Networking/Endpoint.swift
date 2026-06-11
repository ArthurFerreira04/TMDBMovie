//
//  Endpoint.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

struct Endpoint {
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem] = []
}
