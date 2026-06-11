//
//  SplashCoordinator.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class SplashCoordinator: Coordinator {

    let navigationController: UINavigationController
    var onFinish: (() -> Void)?

    private let service: TMDBServiceProtocol
    private let imageLoader: ImageLoaderProtocol

    init(
        navigationController: UINavigationController,
        service: TMDBServiceProtocol,
        imageLoader: ImageLoaderProtocol
    ) {
        self.navigationController = navigationController
        self.service = service
        self.imageLoader = imageLoader
    }

    @MainActor
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)

        let viewModel = SplashViewModel(service: service)
        let vc = SplashViewController(viewModel: viewModel, imageLoader: imageLoader)

        vc.onFinish = { [weak self] in
            self?.onFinish?()
        }

        navigationController.setViewControllers([vc], animated: false)
    }
}
