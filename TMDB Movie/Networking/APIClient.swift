//
//  APIClient.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

protocol APIClientProtocol {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func fetchData(_ url: URL) async throws -> Data
}

final class APIClient: APIClientProtocol {

    private let baseURL: URL
    private let session: URLSession
    private let bearerToken: String

    init(baseURL: URL, bearerToken: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
        self.session = session
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try makeRequest(endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode, data) }

            do {
                return try JSONDecoder.tmdb.decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        } catch is CancellationError {
            throw APIError.cancelled
        }
    }

    func fetchData(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode, data) }
            return data
        } catch is CancellationError {
            throw APIError.cancelled
        }
    }

    private func makeRequest(_ endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if !bearerToken.isEmpty {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

private extension JSONDecoder {
    static let tmdb: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
