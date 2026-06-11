//
//  DescriptionView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class DescriptionView: UIView {

    struct ViewModel {
        let header: HeroHeaderView.ViewModel
        let summary: TitleSummaryView.ViewModel
        let overview: String
        let ctaTitle: String
        let watchProviders: WatchProvidersSectionView.ViewModel
        let cast: CastSectionView.ViewModel
        let categories: ChipsSectionView.ViewModel
        let recommendations: RecommendationsSectionView.ViewModel
    }

    var onTapBack: (() -> Void)?
    var onTapFavorite: (() -> Void)?
    var onTapTrailer: (() -> Void)?
    var onSelectCast: ((CastItem) -> Void)?
    var onSelectRecommendation: ((PosterItem) -> Void)?

    private let backgroundView = GradientBackgroundView(style: .purpleToDarkPurpleToBlack)

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerView = HeroHeaderView()
    private let summaryView = TitleSummaryView()

    private let detailsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColors.surfaceSubtle
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = DSColors.borderSubtle.cgColor
        return view
    }()

    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = DSSpacing.lg
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(
            top: DSSpacing.lg,
            left: DSSpacing.md,
            bottom: DSSpacing.lg,
            right: DSSpacing.md
        )
        return stack
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = DSColors.textEmphasis
        label.font = .dsFonts(.poppinsRegular16)
        label.numberOfLines = 0
        return label
    }()

    private let trailerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = DSColors.accentSecondary
        config.baseForegroundColor = DSColors.textPrimary
        config.cornerStyle = .capsule
        config.title = "Assistir trailer"
        config.image = UIImage(systemName: "play.circle.fill")
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 22, bottom: 16, trailing: 22)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let watchProvidersSectionView = WatchProvidersSectionView()
    private let castSectionView = CastSectionView()
    private let categoriesSectionView = ChipsSectionView()
    private let recommendationsSectionView = RecommendationsSectionView()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = DSSpacing.xl
        return stack
    }()

    private let seamFadeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private let seamFadeLayer = CAGradientLayer()

    private var hasInitializedSafeAreaOffset = false
    private var lastAppliedTopInset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        seamFadeLayer.frame = seamFadeView.bounds
    }

    func configure(_ viewModel: ViewModel, imageLoader: ImageLoaderProtocol) {
        headerView.configure(viewModel.header)
        summaryView.configure(viewModel.summary)
        applyPremiumOverviewStyle(viewModel.overview)

        var config = trailerButton.configuration
        config?.title = viewModel.ctaTitle
        trailerButton.configuration = config

        watchProvidersSectionView.configure(viewModel.watchProviders)
        castSectionView.configure(viewModel.cast, imageLoader: imageLoader)
        categoriesSectionView.configure(viewModel.categories)
        recommendationsSectionView.configure(viewModel.recommendations, imageLoader: imageLoader)
    }

    func setTrailerAvailable(_ isAvailable: Bool, title: String) {
        var config = trailerButton.configuration
        config?.title = title
        config?.image = UIImage(systemName: isAvailable ? "play.circle.fill" : "play.slash")
        config?.baseBackgroundColor = isAvailable
            ? DSColors.accentSecondary
            : DSColors.separator
        config?.baseForegroundColor = isAvailable
            ? DSColors.textPrimary
            : DSColors.textTertiary
        trailerButton.configuration = config
        trailerButton.isEnabled = isAvailable
        trailerButton.alpha = isAvailable ? 1 : 0.72
    }

    func updateSafeAreaInsets(top: CGFloat, bottom: CGFloat = 0) {
        let previousTopInset = lastAppliedTopInset
        let shouldKeepTopAligned = abs(scrollView.contentOffset.y + previousTopInset) < 1.0

        scrollView.contentInset.top = top
        scrollView.verticalScrollIndicatorInsets.top = top
        scrollView.contentInset.bottom = bottom + DSSpacing.xxl
        scrollView.verticalScrollIndicatorInsets.bottom = bottom
        lastAppliedTopInset = top

        if !hasInitializedSafeAreaOffset || shouldKeepTopAligned {
            scrollView.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
            hasInitializedSafeAreaOffset = true
        }
    }

    private func build() {
        backgroundColor = DSColors.background

        addSubview(backgroundView)
        addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(headerView)
        containerView.addSubview(seamFadeView)
        containerView.addSubview(contentStack)

        detailsStack.addArrangedSubview(overviewLabel)
        detailsStack.addArrangedSubview(trailerButton)
        detailsCard.addSubview(detailsStack)

        contentStack.addArrangedSubview(summaryView)
        contentStack.addArrangedSubview(detailsCard)
        contentStack.addArrangedSubview(watchProvidersSectionView)
        contentStack.addArrangedSubview(castSectionView)
        contentStack.addArrangedSubview(categoriesSectionView)
        contentStack.addArrangedSubview(recommendationsSectionView)

        contentStack.setCustomSpacing(DSSpacing.lg, after: summaryView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 440),

            seamFadeView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            seamFadeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            seamFadeView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -100),
            seamFadeView.heightAnchor.constraint(equalToConstant: 120),

            contentStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -52),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DSSpacing.screenHorizontal),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DSSpacing.screenHorizontal),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DSSpacing.xxl),

            detailsStack.topAnchor.constraint(equalTo: detailsCard.topAnchor),
            detailsStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor),
            detailsStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor),
            detailsStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor),

            trailerButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])

        headerView.onTapBack = { [weak self] in self?.onTapBack?() }
        headerView.onTapFavorite = { [weak self] in self?.onTapFavorite?() }
        trailerButton.addTarget(self, action: #selector(didTapTrailer), for: .touchUpInside)

        castSectionView.onSelect = { [weak self] item in
            self?.onSelectCast?(item)
        }

        recommendationsSectionView.onSelect = { [weak self] item in
            self?.onSelectRecommendation?(item)
        }

        seamFadeLayer.colors = [
            UIColor.clear.cgColor,
            DSColors.overlayScrim.cgColor,
            DSColors.shadow.cgColor
        ]
        seamFadeLayer.locations = [0.0, 0.6, 1.0]
        seamFadeLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        seamFadeLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        seamFadeView.layer.addSublayer(seamFadeLayer)
    }

    private func applyPremiumOverviewStyle(_ text: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.2
        paragraph.paragraphSpacing = 4

        overviewLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.dsFonts(.poppinsRegular16),
                .foregroundColor: DSColors.textEmphasis,
                .kern: 0.08,
                .paragraphStyle: paragraph
            ]
        )
    }

    @objc private func didTapTrailer() {
        onTapTrailer?()
    }
}
