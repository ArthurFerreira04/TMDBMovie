//
//  PosterGridTableCell.swift
//  TMDB Movie
//

import UIKit

final class PosterGridTableCell: UITableViewCell {

    static let reuseIdentifier = "PosterGridTableCell"

    var onSelectItem: ((PosterItem) -> Void)?
    var onNearEnd: (() -> Void)?

    private var items: [PosterItem] = []
    private var imageLoader: ImageLoaderProtocol?
    private var heightConstraint: NSLayoutConstraint?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = DSColors.textPrimary
        label.font = .dsFonts(.poppinsBold24)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = DSColors.textSubtle
        label.font = .dsFonts(.poppinsRegular14)
        label.numberOfLines = 2
        return label
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = DSSpacing.xxs
        return stack
    }()

    private let footerSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = DSColors.textPrimary
        spinner.hidesWhenStopped = true
        return spinner
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionHeight()
    }

    func configure(
        section: HomeSection,
        imageLoader: ImageLoaderProtocol,
        isLoadingMore: Bool
    ) {
        self.items = section.items
        self.imageLoader = imageLoader

        titleLabel.text = section.type.title
        subtitleLabel.text = section.type.subtitle
        subtitleLabel.isHidden = section.type.subtitle == nil

        collectionView.reloadData()
        updateCollectionHeight()

        if isLoadingMore {
            footerSpinner.startAnimating()
        } else {
            footerSpinner.stopAnimating()
        }
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subtitleLabel)

        contentView.addSubview(headerStack)
        contentView.addSubview(collectionView)
        contentView.addSubview(footerSpinner)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DSSpacing.sm),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DSSpacing.screenHorizontal),
            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DSSpacing.screenHorizontal),

            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: DSSpacing.md),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DSSpacing.screenHorizontal),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DSSpacing.screenHorizontal),

            footerSpinner.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: DSSpacing.sm),
            footerSpinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            footerSpinner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DSSpacing.md)
        ])

        heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 200)
        heightConstraint?.isActive = true
    }

    private func updateCollectionHeight() {
        let width = collectionView.bounds.width
        guard width > 0 else { return }

        let columns: CGFloat = 3
        let spacing = DSSpacing.md
        let totalSpacing = spacing * (columns - 1)
        let itemWidth = floor((width - totalSpacing) / columns)
        let itemHeight = itemWidth * 1.48
        let rows = max(1, ceil(CGFloat(max(items.count, 1)) / columns))
        heightConstraint?.constant = rows * itemHeight + max(0, rows - 1) * spacing
    }
}

extension PosterGridTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
        onSelectItem?(items[indexPath.item])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 3
        let spacing = DSSpacing.md
        let totalSpacing = spacing * (columns - 1)
        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
        return CGSize(width: width, height: width * 1.48)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let threshold = max(0, items.count - 6)
        if indexPath.item >= threshold {
            onNearEnd?()
        }
    }
}
