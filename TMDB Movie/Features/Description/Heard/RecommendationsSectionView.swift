//
//  RecommendationsSectionView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class RecommendationsSectionView: UIView {

    struct ViewModel: Equatable {
        let title: String
        let items: [PosterItem]
    }

    var onSelect: ((PosterItem) -> Void)?

    private var items: [PosterItem] = []
    private var imageLoader: ImageLoaderProtocol?

    private var lastMeasuredWidth: CGFloat = 0

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = DSColors.textPrimary
        l.font = .dsFonts(.poppinsBold24)
        return l
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = DSSpacing.md
        layout.minimumInteritemSpacing = DSSpacing.md

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(PosterItemCell.self, forCellWithReuseIdentifier: PosterItemCell.reuseIdentifier)
        return cv
    }()

    private var heightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ viewModel: ViewModel, imageLoader: ImageLoaderProtocol) {
        titleLabel.text = viewModel.title
        items = viewModel.items
        self.imageLoader = imageLoader
        collectionView.reloadData()
        setNeedsLayout()
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DSSpacing.md),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = collectionView.bounds.width
        guard width > 0 else { return }

        if abs(width - lastMeasuredWidth) > 0.5 {
            lastMeasuredWidth = width
            updateHeight(forWidth: width)
            collectionView.collectionViewLayout.invalidateLayout()
        } else {
            updateHeight(forWidth: width)
        }
    }

    private func updateHeight(forWidth width: CGFloat) {
        let columns: CGFloat = 3
        let spacing: CGFloat = 16

        let rows = Int(ceil(Double(items.count) / Double(Int(columns))))
        let totalSpacing = spacing * (columns - 1)
        let itemWidth = (width - totalSpacing) / columns
        let itemHeight = itemWidth * 1.45

        let totalHeight = CGFloat(rows) * itemHeight + CGFloat(max(0, rows - 1)) * spacing
        heightConstraint?.constant = totalHeight
    }
}

extension RecommendationsSectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PosterItemCell.reuseIdentifier,
            for: indexPath
        ) as! PosterItemCell

        if let loader = imageLoader {
            cell.configure(item: items[indexPath.item], imageLoader: loader)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(items[indexPath.item])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 16
        let totalSpacing = spacing * (columns - 1)
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width * 1.45)
    }
}
