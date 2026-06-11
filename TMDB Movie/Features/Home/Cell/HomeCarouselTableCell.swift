//
//  HomeCarouselTableCell.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 13/01/26.
//

import UIKit

final class HomeCarouselTableCell: UITableViewCell {

    static let reuseIdentifier = "HomeCarouselTableCell"

    var onSelect: ((PosterItem) -> Void)?

    private var items: [PosterItem] = []
    private var imageLoader: ImageLoaderProtocol?
    private var isLoading: Bool = false

    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = DSColors.textPrimary
        l.font = .dsFonts(.poppinsBold24)
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = DSColors.textTertiary
        l.font = .dsFonts(.poppinsRegular15)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    private let headerStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = DSSpacing.xxs
        return s
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = DSSpacing.sm
        layout.minimumInteritemSpacing = DSSpacing.sm

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.decelerationRate = .fast
        cv.contentInset = UIEdgeInsets(top: 0, left: DSSpacing.screenHorizontal, bottom: 0, right: DSSpacing.screenHorizontal)
        cv.register(PosterItemCell.self, forCellWithReuseIdentifier: PosterItemCell.reuseIdentifier)
        return cv
    }()

    private var heightConstraint: NSLayoutConstraint?
    private let edgeFadeView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSelect = nil
        imageLoader = nil
        items = []
        isLoading = false
        collectionView.setContentOffset(.zero, animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        edgeFadeView.frame = collectionView.frame
        applyEdgeFadeMask()
        applyParallaxEffect()
    }

    func configure(section: HomeSection, imageLoader: ImageLoaderProtocol, isLoading: Bool) {
        self.isLoading = isLoading
        self.imageLoader = imageLoader

        titleLabel.text = section.type.title
        subtitleLabel.text = section.type.subtitle
        subtitleLabel.isHidden = (section.type.subtitle == nil)

        self.items = section.items

        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(container)

        container.addSubview(headerStack)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subtitleLabel)

        container.addSubview(collectionView)
        container.addSubview(edgeFadeView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            headerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: DSSpacing.sm),
            headerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: DSSpacing.screenHorizontal),
            headerStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -DSSpacing.screenHorizontal),

            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: DSSpacing.sm),
            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -DSSpacing.sm)
        ])

        heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 192)
        heightConstraint?.isActive = true

        edgeFadeView.isUserInteractionEnabled = false
        edgeFadeView.backgroundColor = .clear
    }

    private func applyEdgeFadeMask() {
        let gradient = CAGradientLayer()
        gradient.frame = edgeFadeView.bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            DSColors.textPrimary.cgColor,
            DSColors.textPrimary.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 0.07, 0.93, 1.0]
        edgeFadeView.layer.mask = gradient
        edgeFadeView.backgroundColor = DSColors.overlayCarousel
    }

    private func applyParallaxEffect() {
        let centerX = collectionView.bounds.midX + collectionView.contentOffset.x
        for case let cell as PosterItemCell in collectionView.visibleCells {
            let distance = (cell.center.x - centerX) / collectionView.bounds.width
            cell.applyParallax(offset: distance)
        }
    }
}

extension HomeCarouselTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // ✅ skeleton: mostra 10 placeholders quando está carregando
        return isLoading ? 10 : items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PosterItemCell.reuseIdentifier,
            for: indexPath
        ) as! PosterItemCell

        if isLoading {
            cell.configureSkeleton()
            return cell
        }

        if let loader = imageLoader, items.indices.contains(indexPath.item) {
            cell.configure(item: items[indexPath.item], imageLoader: loader)
        } else {
            cell.configureSkeleton()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isLoading, items.indices.contains(indexPath.item) else { return }
        onSelect?(items[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        UIView.animate(withDuration: 0.25, delay: 0.01 * Double(indexPath.item), options: [.curveEaseOut]) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.15) {
            cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.15) {
            cell.transform = .identity
        }
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let itemWidth = 128.0 + layout.minimumLineSpacing
        let insetLeft = collectionView.contentInset.left
        let proposedX = targetContentOffset.pointee.x + insetLeft
        let index = round(proposedX / itemWidth)
        targetContentOffset.pointee.x = (index * itemWidth) - insetLeft
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyParallaxEffect()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 192)
    }
}
