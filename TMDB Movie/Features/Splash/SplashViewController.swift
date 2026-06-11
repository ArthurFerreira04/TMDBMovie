//
//  SplashViewController.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import UIKit

final class SplashViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let viewModel: SplashViewModel
    private let imageLoader: ImageLoaderProtocol

    private var didRunEntranceAnimation = false
    private var isFinishing = false
    private var viewModelState: SplashViewModel.State = .idle

    private let finishHaptic = UIImpactFeedbackGenerator(style: .light)

    private let heroBackgroundView = SplashHeroBackgroundView()
    private let contentView = SplashContentView()
    private let statusView = SplashStatusView()

    private let contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var tapToContinueGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(didTapContent))
        g.isEnabled = false
        return g
    }()

    init(viewModel: SplashViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        finishHaptic.prepare()
        contentView.onSkipTapped = { [weak self] in
            self?.performFinish()
        }
        statusView.onRetryTapped = { [weak self] in
            self?.didTapRetry()
        }
        setupView()
        view.addGestureRecognizer(tapToContinueGesture)
        SplashMotionEffectsConfigurator.apply(
            heroBackground: heroBackgroundView,
            contentContainer: contentContainer
        )
        bind()
        viewModel.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        heroBackgroundView.start()
        runEntranceAnimationIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        heroBackgroundView.stop()
        viewModel.cancel()
    }

    @objc private func didTapRetry() {
        statusView.prepareForRetry()
        viewModel.load()
    }

    @objc private func didTapContent() {
        guard case .loaded = viewModelState else { return }
        performFinish()
    }

    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.viewModelState = state
            self.statusView.render(state)

            switch state {
            case .idle, .loading:
                self.contentView.setHintVisible(false, animated: false)
                self.tapToContinueGesture.isEnabled = false
            case .loaded:
                self.tapToContinueGesture.isEnabled = true
                self.contentView.setHintVisible(true, animated: true)
            case .error:
                self.contentView.setHintVisible(false, animated: false)
                self.tapToContinueGesture.isEnabled = false
            }
        }

        viewModel.onBackgroundURLsChange = { [weak self] urls in
            guard let self else { return }
            self.heroBackgroundView.configure(
                urls: urls,
                imageLoader: self.imageLoader,
                interval: 4.2
            )
        }
    }

    private func performFinish() {
        guard !isFinishing else { return }
        isFinishing = true
        finishHaptic.impactOccurred()
        onFinish?()
    }

    private func runEntranceAnimationIfNeeded() {
        guard !didRunEntranceAnimation else { return }
        didRunEntranceAnimation = true

        let animatedViews = contentView.entranceAnimationViews + [statusView.entranceAnimationView]

        contentView.prepareForEntranceAnimation()
        let statusEntranceView = statusView.entranceAnimationView
        statusEntranceView.alpha = 0
        statusEntranceView.transform = CGAffineTransform(translationX: 0, y: 16)

        heroBackgroundView.animateBottomGradientEntrance()

        let showHint = viewModelState == .loaded
        for (index, animatedView) in animatedViews.enumerated() {
            UIView.animate(
                withDuration: EntranceAnimation.itemDuration,
                delay: EntranceAnimation.staggerDelay * Double(index),
                usingSpringWithDamping: EntranceAnimation.springDamping,
                initialSpringVelocity: EntranceAnimation.springVelocity,
                options: [.curveEaseOut]
            ) {
                animatedView.alpha = self.contentView.entranceAlpha(for: animatedView, showHint: showHint)
                animatedView.transform = .identity
            }
        }
    }
}

extension SplashViewController: ViewCodeType {

    func buildViewHierarchy() {
        view.addSubview(heroBackgroundView)
        view.addSubview(contentContainer)

        contentContainer.addSubview(contentView)
        contentContainer.addSubview(statusView)
    }

    func setupConstraints() {
        heroBackgroundView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )

        contentContainer.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            leftConstant: 24,
            rightConstant: 24
        )

        contentView.anchor(
            top: contentContainer.topAnchor,
            left: contentContainer.leftAnchor,
            bottom: contentContainer.bottomAnchor,
            right: contentContainer.rightAnchor
        )

        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            statusView.bottomAnchor.constraint(equalTo: contentView.hintTopAnchor, constant: -14)
        ])
    }

    func setupAdditionalConfiguration() {
        view.backgroundColor = DSColors.background
        tapToContinueGesture.cancelsTouchesInView = false
    }
}

private enum EntranceAnimation {
    static let itemDuration: TimeInterval = 0.55
    static let staggerDelay: TimeInterval = 0.06
    static let springDamping: CGFloat = 0.9
    static let springVelocity: CGFloat = 0.35
}
