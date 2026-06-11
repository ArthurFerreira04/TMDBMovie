//
//  WatchProvidersSectionView.swift
//  TMDB Movie
//

import UIKit

final class WatchProvidersSectionView: UIView {

    struct ViewModel: Equatable {
        let title: String
        let providers: [WatchProviderItem]
    }

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
        label.text = "Disponível para streaming no Brasil"
        return label
    }()

    private let chipsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = DSSpacing.sm
        stack.alignment = .leading
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ viewModel: ViewModel) {
        isHidden = viewModel.providers.isEmpty
        titleLabel.text = viewModel.title

        chipsStack.arrangedSubviews.forEach {
            chipsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = DSSpacing.sm
        row.alignment = .center

        for provider in viewModel.providers.prefix(8) {
            row.addArrangedSubview(makeChip(title: provider.name))
        }

        chipsStack.addArrangedSubview(row)

        if viewModel.providers.count > 8 {
            let more = UILabel()
            more.font = .dsFonts(.poppinsRegular14)
            more.textColor = DSColors.textTertiary
            more.text = "+\(viewModel.providers.count - 8) plataformas"
            chipsStack.addArrangedSubview(more)
        }
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(chipsStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DSSpacing.xxs),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            chipsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DSSpacing.md),
            chipsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            chipsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            chipsStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func makeChip(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .dsFonts(.poppinsBold14)
        label.textColor = DSColors.textPrimary

        let container = UIView()
        container.backgroundColor = DSColors.surface
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = DSColors.border.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        return container
    }
}
