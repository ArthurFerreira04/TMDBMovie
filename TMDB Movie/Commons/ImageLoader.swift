//
//  ImageLoader.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import UIKit

protocol ImageLoaderProtocol {
    func load(_ url: URL) async throws -> UIImage
}

enum ImageLoaderError: Error, Equatable {
    case invalidImageData
}

actor ImageLoader: ImageLoaderProtocol {

    private let client: APIClientProtocol
    private let cache: NSCache<NSURL, UIImage>
    private var inFlight: [URL: Task<UIImage, Error>] = [:]

    init(client: APIClientProtocol, cacheCountLimit: Int = 300, cacheTotalCostLimit: Int = 120 * 1024 * 1024) {
        self.client = client
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = cacheCountLimit
        cache.totalCostLimit = cacheTotalCostLimit
        self.cache = cache
    }

    func load(_ url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        if let existing = inFlight[url] {
            return try await existing.value
        }

        let task = Task<UIImage, Error> { [client, cache] in
            let data = try await client.fetchData(url)
            guard let image = UIImage(data: data) else { throw ImageLoaderError.invalidImageData }
            let cost = ImageLoader.cost(for: image)
            cache.setObject(image, forKey: url as NSURL, cost: cost)
            return image
        }

        inFlight[url] = task

        do {
            let image = try await task.value
            inFlight[url] = nil
            return image
        } catch {
            inFlight[url] = nil
            throw error
        }
    }

    private static func cost(for image: UIImage) -> Int {
        let scale = image.scale
        let pixelsWide = Int(image.size.width * scale)
        let pixelsHigh = Int(image.size.height * scale)
        return pixelsWide * pixelsHigh * 4
    }
}
