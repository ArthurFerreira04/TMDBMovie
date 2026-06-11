//
//  AppCoordinator.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController

    private let service: TMDBServiceProtocol
    private let imageLoader: ImageLoaderProtocol
    private let favoritesStore: FavoritesStoreProtocol

    private var childCoordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        service: TMDBServiceProtocol,
        imageLoader: ImageLoaderProtocol,
        favoritesStore: FavoritesStoreProtocol
    ) {
        self.navigationController = navigationController
        self.service = service
        self.imageLoader = imageLoader
        self.favoritesStore = favoritesStore
    }

    func start() {
        Task { @MainActor in
            self.showSplash()
        }
    }

    @MainActor
    private func showSplash() {
        let coordinator = SplashCoordinator(
            navigationController: navigationController,
            service: service,
            imageLoader: imageLoader
        )

        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self else { return }

            if let coordinator {
                self.childCoordinators.removeAll { $0 === coordinator }
            }

            Task { @MainActor in
                self.showHome()
            }
        }

        childCoordinators.append(coordinator)
        coordinator.start()
    }

    @MainActor
    private func showHome() {
        let coordinator = HomeCoordinator(
            navigationController: navigationController,
            service: service,
            imageLoader: imageLoader,
            favoritesStore: favoritesStore
        )

        childCoordinators.append(coordinator)

        UIView.transition(
            with: navigationController.view,
            duration: 0.42,
            options: .transitionCrossDissolve
        ) {
            coordinator.start()
        }
    }
}
