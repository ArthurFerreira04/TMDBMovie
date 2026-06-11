//
//  FavoritesCoordinator.swift
//  TMDB Movie
//

import UIKit

final class FavoritesCoordinator: Coordinator {

    let navigationController: UINavigationController

    var onFinish: (() -> Void)?

    private let favoritesStore: FavoritesStoreProtocol
    private let imageLoader: ImageLoaderProtocol
    private let onSelectMovie: (PosterItem) -> Void

    private weak var viewController: FavoritesViewController?

    init(
        navigationController: UINavigationController,
        favoritesStore: FavoritesStoreProtocol,
        imageLoader: ImageLoaderProtocol,
        onSelectMovie: @escaping (PosterItem) -> Void
    ) {
        self.navigationController = navigationController
        self.favoritesStore = favoritesStore
        self.imageLoader = imageLoader
        self.onSelectMovie = onSelectMovie
    }

    @MainActor
    func start() {
        let viewModel = FavoritesViewModel(store: favoritesStore)
        let viewController = FavoritesViewController(viewModel: viewModel, imageLoader: imageLoader)
        self.viewController = viewController

        viewController.onBack = { [weak self] in
            self?.popFavorites()
        }

        viewController.onExplore = { [weak self] in
            self?.popFavorites()
        }

        viewController.onSelectFavorite = { [weak self] item in
            self?.onSelectMovie(item)
        }

        navigationController.pushViewController(viewController, animated: true)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }

    @MainActor
    private func popFavorites() {
        guard navigationController.topViewController === viewController else { return }
        navigationController.popViewController(animated: true)
        onFinish?()
    }
}
