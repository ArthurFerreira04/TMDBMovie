//
//  CategoryTabCell.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import UIKit

final class CategoryTabCell: UICollectionViewCell {

    static let reuseIdentifier = "CategoryTabCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .dsFonts(.poppinsBold14)
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet { updateStyle() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(title: String) {
        titleLabel.text = title
        updateStyle()
    }

    private func setup() {
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DSSpacing.xs),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DSSpacing.xs),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DSSpacing.md),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DSSpacing.md)
        ])

        updateStyle()
    }

    private func updateStyle() {
        if isSelected {
            contentView.backgroundColor = DSColors.accentSecondary
            contentView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = DSColors.textPrimary
        } else {
            contentView.backgroundColor = DSColors.surfaceInset
            contentView.layer.borderColor = DSColors.overlayLight.cgColor
            titleLabel.textColor = DSColors.textHighlight
        }
    }
}
