//
//  FavoritesView.swift
//  TMDB Movie
//

import UIKit

final class FavoritesView: UIView, ViewCodeType {

    var onTapBack: (() -> Void)?
    var onTapEdit: (() -> Void)?
    var onTapClearAll: (() -> Void)?
    var onTapExplore: (() -> Void)?
    var onSelectItem: ((PosterItem) -> Void)?
    var onRemoveItem: ((Int) -> Void)?

    private let backgroundView = GradientBackgroundView(style: .purpleToDarkPurpleToBlack)
    private let headerView = FavoritesHeaderView()
    private let feedbackView = DSFeedbackView()

    private var items: [PosterItem] = []
    private var isEditing = false
    private var imageLoader: ImageLoaderProtocol?

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(FavoritePosterCell.self, forCellWithReuseIdentifier: FavoritePosterCell.reuseIdentifier)
        return cv
    }()

    private let contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) { nil }

    func setImageLoader(_ loader: ImageLoaderProtocol) {
        imageLoader = loader
    }

    func apply(state: FavoritesViewModel.ViewState) {
        headerView.configure(.init(
            countLabel: state.countLabel,
            isEditing: state.isEditing,
            showsEditControls: state.showsEditControls
        ))

        items = state.items
        isEditing = state.isEditing

        collectionView.isHidden = state.isEmpty
        collectionView.allowsSelection = !state.isEditing
        collectionView.reloadData()

        if state.isEmpty {
            feedbackView.apply(.empty(
                title: "Nenhum favorito ainda",
                message: "Salve filmes na tela de detalhes para vê-los aqui.",
                actionTitle: "Explorar catálogo"
            ))
        } else {
            feedbackView.apply(.hidden)
        }
    }

    func buildViewHierarchy() {
        backgroundColor = DSColors.background
        addSubview(backgroundView)
        addSubview(headerView)
        addSubview(contentContainer)
        contentContainer.addSubview(collectionView)
        contentContainer.addSubview(feedbackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: DSSpacing.sm),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSSpacing.screenHorizontal),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.screenHorizontal),

            contentContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: DSSpacing.md),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),

            feedbackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: DSSpacing.screenHorizontal),
            feedbackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -DSSpacing.screenHorizontal),
            feedbackView.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor)
        ])
    }

    func setupAdditionalConfiguration() {
        headerView.onTapBack = { [weak self] in self?.onTapBack?() }
        headerView.onTapEdit = { [weak self] in self?.onTapEdit?() }
        headerView.onTapClearAll = { [weak self] in self?.onTapClearAll?() }
        feedbackView.onAction = { [weak self] in self?.onTapExplore?() }
    }

    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
            guard let self else { return nil }

            let columns = self.columnCount(for: environment)
            let spacing = DSSpacing.md
            let horizontalInset = DSSpacing.screenHorizontal
            let width = environment.container.effectiveContentSize.width - horizontalInset * 2
            let totalSpacing = spacing * CGFloat(columns - 1)
            let itemWidth = floor((width - totalSpacing) / CGFloat(columns))
            let itemHeight = itemWidth * 1.48

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(itemHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(itemHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: columns
            )
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: horizontalInset,
                bottom: DSSpacing.xxl,
                trailing: horizontalInset
            )
            return section
        }
    }

    private func columnCount(for environment: NSCollectionLayoutEnvironment) -> Int {
        let width = environment.container.effectiveContentSize.width
        if width >= 700 { return 4 }
        if width >= 500 { return 3 }
        return 3
    }
}

extension FavoritesView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoritePosterCell.reuseIdentifier,
            for: indexPath
        ) as! FavoritePosterCell

        guard let imageLoader else { return cell }

        let item = items[indexPath.item]
        cell.configure(item: item, imageLoader: imageLoader, isEditing: isEditing)
        cell.setEditing(isEditing, animated: true)
        cell.onRemove = { [weak self] in
            guard let self,
                  let index = self.items.firstIndex(where: { $0.id == item.id })
            else { return }
            self.onRemoveItem?(index)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditing else { return }
        onSelectItem?(items[indexPath.item])
    }
}
