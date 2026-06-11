//
//  DescriptionViewController.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//
import UIKit

final class DescriptionViewController: UIViewController {

    var onBack: (() -> Void)?
    var onTapTrailer: ((String) -> Void)?
    var onSelectRecommendation: ((PosterItem) -> Void)?

    private let contentView = DescriptionView()
    private let viewModel: DescriptionViewModel
    private let imageLoader: ImageLoaderProtocol
    private lazy var feedbackOverlay = installFeedbackOverlay(on: contentView)

    private var headerTask: Task<Void, Never>?
    private var trailerKey: String?
    private var latestViewModel: DescriptionView.ViewModel?
    private let selectionHaptic = UISelectionFeedbackGenerator()
    private let impactHaptic = UIImpactFeedbackGenerator(style: .light)

    init(viewModel: DescriptionViewModel, imageLoader: ImageLoaderProtocol) {
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
        selectionHaptic.prepare()
        impactHaptic.prepare()
        bindView()
        bindViewModel()
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.updateSafeAreaInsets(
            top: 0,
            bottom: view.safeAreaInsets.bottom
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.cancel()
    }

    deinit {
        headerTask?.cancel()
    }

    private func bindView() {
        contentView.onTapBack = { [weak self] in
            self?.selectionHaptic.selectionChanged()
            self?.onBack?()
        }

        contentView.onTapFavorite = { [weak self] in
            self?.impactHaptic.impactOccurred()
            self?.viewModel.toggleFavorite()
        }

        contentView.onTapTrailer = { [weak self] in
            guard let self, let key = self.trailerKey else { return }
            self.impactHaptic.impactOccurred()
            self.onTapTrailer?(key)
        }

        contentView.onSelectRecommendation = { [weak self] item in
            self?.selectionHaptic.selectionChanged()
            self?.onSelectRecommendation?(item)
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            self.applyDetailFeedback(
                for: state,
                contentView: self.contentView,
                feedbackOverlay: self.feedbackOverlay,
                onRetry: { [weak self] in self?.viewModel.load() }
            )

            guard case .loaded(let output) = state else { return }

            self.trailerKey = output.trailerKey
            self.latestViewModel = output.viewModel
            self.contentView.configure(output.viewModel, imageLoader: self.imageLoader)
            self.contentView.setTrailerAvailable(
                output.trailerKey != nil,
                title: output.viewModel.ctaTitle
            )
            self.loadBackdropIfNeeded(url: output.backdropURL)
        }
    }

    private func loadBackdropIfNeeded(url: URL?) {
        headerTask?.cancel()
        headerTask = DescriptionBackdropLoader.load(
            url: url,
            currentViewModel: latestViewModel,
            imageLoader: imageLoader
        ) { [weak self] updatedViewModel in
            guard let self else { return }
            self.latestViewModel = updatedViewModel
            self.contentView.configure(updatedViewModel, imageLoader: self.imageLoader)
        }
    }
}
