//
//  HomeHeaderView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 13/01/26.
//

import UIKit

final class HomeHeaderView: UIView {

    var onTextChange: ((String) -> Void)?
    var onSearch: ((String) -> Void)?
    var onSelectGenreIndex: ((Int) -> Void)?
    var onSelectCatalog: ((MediaKind) -> Void)?
    var onTapProfile: (() -> Void)?

    private var genres: [TMDBGenre] = []
    private var selectedGenreIndex: Int = 0

    private var genreTitles: [String] {
        ["Todos"] + genres.map(\.name)
    }

    // MARK: - Layout

    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()

    private let topSpacer = UIView()

    private let titleRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = DSSpacing.md
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .dsFonts(.poppinsBold24)
        label.textColor = DSColors.textPrimary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .dsFonts(.poppinsRegular14)
        label.textColor = DSColors.textMuted
        label.numberOfLines = 2
        return label
    }()

    private lazy var profileButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "person.fill")
        config.baseForegroundColor = DSColors.iconPrimary
        config.background.backgroundColor = DSColors.overlayLight
        config.background.cornerRadius = 18
        config.background.strokeColor = DSColors.separator
        config.background.strokeWidth = 1
        let button = UIButton(configuration: config)
        button.accessibilityLabel = "Perfil"
        button.isUserInteractionEnabled = false
        button.alpha = 0.9
        return button
    }()

    private lazy var catalogControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Filmes", "Séries"])
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([
            .font: UIFont.dsFonts(.poppinsBold14),
            .foregroundColor: DSColors.textSecondary
        ], for: .normal)
        control.setTitleTextAttributes([
            .font: UIFont.dsFonts(.poppinsBold14),
            .foregroundColor: DSColors.textPrimary
        ], for: .selected)
        control.selectedSegmentTintColor = DSColors.accentSecondary.withAlphaComponent(0.35)
        control.backgroundColor = DSColors.overlayLight
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(catalogChanged), for: .valueChanged)
        return control
    }()

    private let searchBarView = SearchBarView()

    private lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = DSSpacing.sm
        layout.minimumInteritemSpacing = DSSpacing.sm
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.allowsMultipleSelection = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(CategoryTabCell.self, forCellWithReuseIdentifier: CategoryTabCell.reuseIdentifier)
        return cv
    }()

    private var topSpacerHeightConstraint: NSLayoutConstraint?
    private var genreHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        bindSearch()
        applyCopy()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - API

    func configureGenres(_ genres: [TMDBGenre]) {
        self.genres = genres
        genreCollectionView.reloadData()

        let maxIndex = max(0, genreTitles.count - 1)
        selectedGenreIndex = min(selectedGenreIndex, maxIndex)
        genreCollectionView.selectItem(
            at: IndexPath(item: selectedGenreIndex, section: 0),
            animated: false,
            scrollPosition: []
        )
    }

    func setSearchText(_ text: String) {
        searchBarView.setText(text)
    }

    func setCatalog(_ kind: MediaKind) {
        catalogControl.selectedSegmentIndex = kind == .movie ? 0 : 1
    }

    func applyScrollProgress(_ progress: CGFloat) {
        let clamped = min(1, max(0, progress))
        titleLabel.alpha = 1 - clamped
        subtitleLabel.alpha = 1 - (0.85 * clamped)
        profileButton.alpha = 1 - (0.45 * clamped)

        let scale = 1 - (0.04 * clamped)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    func updateTopInset(_ topInset: CGFloat) {
        topSpacerHeightConstraint?.constant = max(DSSpacing.xs, topInset + DSSpacing.xs)
    }

    // MARK: - Build

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacerHeightConstraint = topSpacer.heightAnchor.constraint(equalToConstant: DSSpacing.md)
        topSpacerHeightConstraint?.isActive = true

        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.setContentHuggingPriority(.required, for: .horizontal)
        profileButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            profileButton.widthAnchor.constraint(equalToConstant: 36),
            profileButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        titleRowStack.addArrangedSubview(titleLabel)
        titleRowStack.addArrangedSubview(profileButton)

        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        genreCollectionView.translatesAutoresizingMaskIntoConstraints = false
        genreHeightConstraint = genreCollectionView.heightAnchor.constraint(equalToConstant: 36)
        genreHeightConstraint?.isActive = true

        rootStack.addArrangedSubview(topSpacer)
        rootStack.addArrangedSubview(titleRowStack)
        rootStack.addArrangedSubview(subtitleLabel)
        rootStack.addArrangedSubview(catalogControl)
        rootStack.addArrangedSubview(searchBarView)
        rootStack.addArrangedSubview(genreCollectionView)

        rootStack.setCustomSpacing(DSSpacing.sm, after: titleRowStack)
        rootStack.setCustomSpacing(DSSpacing.xl, after: subtitleLabel)
        rootStack.setCustomSpacing(DSSpacing.md, after: catalogControl)
        rootStack.setCustomSpacing(DSSpacing.lg, after: searchBarView)

        addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSSpacing.screenHorizontal),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.screenHorizontal),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DSSpacing.md)
        ])

        searchBarView.configure(.init(placeholder: "Buscar no catálogo", text: nil, isSearchEnabled: true))
        NSLayoutConstraint.activate([
            catalogControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func catalogChanged() {
        let kind: MediaKind = catalogControl.selectedSegmentIndex == 0 ? .movie : .tv
        onSelectCatalog?(kind)
    }

    private func applyCopy() {
        titleLabel.attributedText = NSAttributedString(
            string: "O que você quer assistir hoje?",
            attributes: [
                .font: UIFont.dsFonts(.poppinsBold24),
                .foregroundColor: DSColors.textPrimary,
                .kern: -0.4
            ]
        )
        subtitleLabel.attributedText = NSAttributedString(
            string: "Descubra os títulos mais quentes do momento",
            attributes: [
                .font: UIFont.dsFonts(.poppinsRegular14),
                .foregroundColor: DSColors.textMuted,
                .kern: 0.06
            ]
        )
    }

    private func bindSearch() {
        searchBarView.onTextChange = { [weak self] text in
            self?.onTextChange?(text)
        }
        searchBarView.onSearch = { [weak self] text in
            self?.onSearch?(text)
        }
    }

}

// MARK: - Genres

extension HomeHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        genreTitles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryTabCell.reuseIdentifier,
            for: indexPath
        ) as! CategoryTabCell

        let title = genreTitles.indices.contains(indexPath.item) ? genreTitles[indexPath.item] : ""
        cell.configure(title: title)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGenreIndex = indexPath.item
        onSelectGenreIndex?(indexPath.item)
    }
}
