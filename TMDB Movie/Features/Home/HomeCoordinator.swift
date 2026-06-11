//
//  HomeCoordinator.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit
import SafariServices

final class HomeCoordinator: Coordinator {

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

    @MainActor
    func start() {
        let viewModel = HomeViewModel(service: service)
        let vc = HomeViewController(viewModel: viewModel, imageLoader: imageLoader)

        vc.onSelectPoster = { [weak self] item in
            guard let self else { return }
            Task { @MainActor in
                self.showDescription(item: item)
            }
        }

        vc.onTapFavorites = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.showFavorites()
            }
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    @MainActor
    private func showDescription(item: PosterItem) {
        let vm = DescriptionViewModel(
            service: service,
            favoritesStore: favoritesStore,
            mediaId: item.id,
            mediaKind: item.mediaKind,
            seedPosterItem: item
        )
        let vc = DescriptionViewController(viewModel: vm, imageLoader: imageLoader)

        vc.onBack = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                let transition = CATransition()
                transition.type = .push
                transition.subtype = .fromLeft
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.navigationController.view.layer.add(transition, forKey: kCATransition)
                self.navigationController.popViewController(animated: false)
            }
        }

        vc.onTapTrailer = { [weak self] key in
            guard let self else { return }
            Task { @MainActor in
                self.showTrailer(youtubeKey: key)
            }
        }

        vc.onSelectRecommendation = { [weak self] recItem in
            guard let self else { return }
            Task { @MainActor in
                self.showDescription(item: recItem)
            }
        }

        let transition = CATransition()
        transition.type = .push
        transition.subtype = .fromRight
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.pushViewController(vc, animated: false)
    }

    @MainActor
    private func showFavorites() {
        let coordinator = FavoritesCoordinator(
            navigationController: navigationController,
            favoritesStore: favoritesStore,
            imageLoader: imageLoader,
            onSelectMovie: { [weak self] item in
                self?.showDescription(item: item)
            }
        )

        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.childCoordinators.removeAll { $0 === coordinator }
        }

        childCoordinators.append(coordinator)
        coordinator.start()
    }

    @MainActor
    private func showTrailer(youtubeKey: String) {
        guard let url = URL(string: "https://www.youtube.com/watch?v=\(youtubeKey)") else { return }
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .pageSheet
        navigationController.present(safari, animated: true)
    }
}
