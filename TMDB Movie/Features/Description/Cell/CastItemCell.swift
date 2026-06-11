//
//  CastItemCell.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class CastItemCell: UICollectionViewCell {

    static let reuseIdentifier = "CastItemCell"

    private var task: Task<Void, Never>?

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = DSColors.overlayLight
        iv.layer.borderWidth = 1
        iv.layer.borderColor = DSColors.borderSubtle.cgColor
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = DSColors.iconPrimary
        label.font = .dsFonts(.poppinsRegular12)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DSSpacing.xs
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        imageView.image = nil
        imageView.backgroundColor = DSColors.overlayLight
        nameLabel.text = nil
    }

    func configure(item: CastItem, imageLoader: ImageLoaderProtocol) {
        nameLabel.text = item.name
        imageView.image = nil

        guard let url = item.profileURL else { return }

        task = Task { [weak self] in
            guard let self else { return }
            if let image = try? await imageLoader.load(url) {
                await MainActor.run {
                    self.imageView.image = image
                    self.imageView.backgroundColor = .clear
                }
            }
        }
    }

    private func build() {
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(nameLabel)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 76),
            imageView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }
}
