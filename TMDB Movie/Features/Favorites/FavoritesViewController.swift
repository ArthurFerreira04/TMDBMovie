//
//  FavoritesViewController.swift
//  TMDB Movie
//

import UIKit

final class FavoritesViewController: UIViewController {

    var onBack: (() -> Void)?
    var onSelectFavorite: ((PosterItem) -> Void)?
    var onExplore: (() -> Void)?

    private let contentView = FavoritesView()
    private let viewModel: FavoritesViewModel
    private let imageLoader: ImageLoaderProtocol

    private let selectionHaptic = UISelectionFeedbackGenerator()
    private let impactHaptic = UIImpactFeedbackGenerator(style: .light)
    private let notificationHaptic = UINotificationFeedbackGenerator()

    init(viewModel: FavoritesViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        selectionHaptic.prepare()
        impactHaptic.prepare()

        contentView.setImageLoader(imageLoader)
        bindView()
        bindViewModel()
        viewModel.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            viewModel.stop()
        }
    }

    private func bindView() {
        contentView.onTapBack = { [weak self] in
            guard let self else { return }
            self.selectionHaptic.selectionChanged()
            if let onBack = self.onBack {
                onBack()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }

        contentView.onTapEdit = { [weak self] in
            self?.impactHaptic.impactOccurred()
            self?.viewModel.toggleEditMode()
        }

        contentView.onTapClearAll = { [weak self] in
            self?.presentClearAllConfirmation()
        }

        contentView.onTapExplore = { [weak self] in
            self?.selectionHaptic.selectionChanged()
            self?.onExplore?()
        }

        contentView.onSelectItem = { [weak self] item in
            self?.selectionHaptic.selectionChanged()
            self?.onSelectFavorite?(item)
        }

        contentView.onRemoveItem = { [weak self] index in
            self?.impactHaptic.impactOccurred()
            self?.viewModel.removeItem(at: index)
            self?.notificationHaptic.notificationOccurred(.success)
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.contentView.apply(state: state)
        }
    }

    private func presentClearAllConfirmation() {
        let alert = UIAlertController(
            title: "Limpar favoritos?",
            message: "Todos os títulos salvos serão removidos desta lista.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Limpar", style: .destructive) { [weak self] _ in
            self?.viewModel.clearAll()
            self?.notificationHaptic.notificationOccurred(.success)
        })
        present(alert, animated: true)
    }
}
