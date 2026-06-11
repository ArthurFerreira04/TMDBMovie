//
//  DescriptionBackdropLoader.swift
//  TMDB Movie
//

import UIKit

enum DescriptionBackdropLoader {

    @MainActor
    static func load(
        url: URL?,
        currentViewModel: DescriptionView.ViewModel?,
        imageLoader: ImageLoaderProtocol,
        onUpdate: @escaping (DescriptionView.ViewModel) -> Void
    ) -> Task<Void, Never>? {
        guard let url, let current = currentViewModel else { return nil }

        return Task {
            guard let image = try? await imageLoader.load(url) else { return }
            onUpdate(current.withHeaderImage(image))
        }
    }
}

private extension DescriptionView.ViewModel {

    func withHeaderImage(_ image: UIImage) -> Self {
        .init(
            header: .init(image: image, isFavorite: header.isFavorite),
            summary: summary,
            overview: overview,
            ctaTitle: ctaTitle,
            watchProviders: watchProviders,
            cast: cast,
            categories: categories,
            recommendations: recommendations
        )
    }
}
