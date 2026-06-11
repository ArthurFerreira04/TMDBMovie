//
//  FavoritePosterCell.swift
//  TMDB Movie
//

import UIKit

final class FavoritePosterCell: UICollectionViewCell {

    static let reuseIdentifier = "FavoritePosterCell"

    var onRemove: (() -> Void)?

    private var task: Task<Void, Never>?

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.shadowColor = DSColors.shadow.cgColor
        view.layer.shadowOpacity = 0.42
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.backgroundColor = DSColors.overlayLight
        iv.layer.borderWidth = 1
        iv.layer.borderColor = DSColors.borderSubtle.cgColor
        return iv
    }()

    private let shimmer = ShimmerView()

    private lazy var removeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "minus")
        config.baseBackgroundColor = DSColors.accentSecondary
        config.baseForegroundColor = DSColors.textPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.addTarget(self, action: #selector(didTapRemove), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 16).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        onRemove = nil
        imageView.image = nil
        shimmer.isHidden = false
        shimmer.start()
        setEditing(false, animated: false)
    }

    func configure(item: PosterItem, imageLoader: ImageLoaderProtocol, isEditing: Bool) {
        task?.cancel()
        imageView.image = nil
        shimmer.isHidden = false
        shimmer.start()

        setEditing(isEditing, animated: false)

        guard let url = item.posterURL else { return }

        task = Task { [weak self] in
            guard let self else { return }
            if let image = try? await imageLoader.load(url) {
                await MainActor.run {
                    self.imageView.image = image
                    self.shimmer.stop()
                    self.shimmer.isHidden = true
                }
            }
        }
    }

    func setEditing(_ isEditing: Bool, animated: Bool) {
        let updates = {
            self.removeButton.alpha = isEditing ? 1 : 0
            self.removeButton.isUserInteractionEnabled = isEditing
            self.transform = isEditing
                ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                : .identity
        }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut, animations: updates)
        } else {
            updates()
        }
    }

    private func build() {
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.addSubview(imageView)
        cardView.addSubview(shimmer)
        contentView.addSubview(removeButton)

        shimmer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DSSpacing.xs),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DSSpacing.xs),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            shimmer.topAnchor.constraint(equalTo: cardView.topAnchor),
            shimmer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            shimmer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            shimmer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            removeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -4),
            removeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 4),
            removeButton.widthAnchor.constraint(equalToConstant: 28),
            removeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    @objc private func didTapRemove() {
        onRemove?()
    }
}
