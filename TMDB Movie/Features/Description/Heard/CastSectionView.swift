//
//  CastSectionView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class CastSectionView: UIView {

    struct ViewModel: Equatable {
        let title: String
        let items: [CastItem]
    }

    var onSelect: ((CastItem) -> Void)?

    private var items: [CastItem] = []
    private var imageLoader: ImageLoaderProtocol?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = DSColors.textPrimary
        label.font = .dsFonts(.poppinsBold24)
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = DSSpacing.md
        layout.minimumInteritemSpacing = DSSpacing.md

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: DSSpacing.md)
        cv.dataSource = self
        cv.delegate = self
        cv.register(CastItemCell.self, forCellWithReuseIdentifier: CastItemCell.reuseIdentifier)
        return cv
    }()

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
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 124)
        ])
    }
}

extension CastSectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CastItemCell.reuseIdentifier,
            for: indexPath
        ) as! CastItemCell

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
        CGSize(width: 88, height: 124)
    }
}
