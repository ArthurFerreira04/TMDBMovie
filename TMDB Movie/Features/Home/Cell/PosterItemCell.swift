//
//  PosterItemCell.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import UIKit

final class PosterItemCell: UICollectionViewCell {

    static let reuseIdentifier = "PosterItemCell"

    private var task: Task<Void, Never>?

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 18
        v.layer.shadowColor = DSColors.shadow.cgColor
        v.layer.shadowOpacity = 0.35
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 18
        iv.backgroundColor = DSColors.overlayLight
        return iv
    }()

    private let shimmer = ShimmerView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.addSubview(imageView)
        cardView.addSubview(shimmer)

        shimmer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            shimmer.topAnchor.constraint(equalTo: cardView.topAnchor),
            shimmer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            shimmer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            shimmer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 18).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        transform = .identity
        imageView.transform = .identity
        imageView.image = nil
        shimmer.isHidden = false
        shimmer.start()
    }

    func configureSkeleton() {
        imageView.image = nil
        shimmer.isHidden = false
        shimmer.start()
    }

    func configure(item: PosterItem, imageLoader: ImageLoaderProtocol) {
        task?.cancel()
        imageView.image = nil

        shimmer.isHidden = false
        shimmer.start()

        guard let url = item.posterURL else { return }

        task = Task { [weak self] in
            guard let self else { return }
            guard let image = try? await imageLoader.load(url) else { return }
            await MainActor.run {
                self.imageView.image = image
                self.shimmer.stop()
                self.shimmer.isHidden = true
            }
        }
    }

    func applyParallax(offset: CGFloat) {
        let clamped = max(-1, min(1, offset))
        imageView.transform = CGAffineTransform(translationX: clamped * 14, y: 0)
    }
}
