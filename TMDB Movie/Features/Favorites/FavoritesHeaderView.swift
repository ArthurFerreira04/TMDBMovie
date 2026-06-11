//
//  FavoritesHeaderView.swift
//  TMDB Movie
//

import UIKit

final class FavoritesHeaderView: UIView {

    struct ViewModel: Equatable {
        let countLabel: String
        let isEditing: Bool
        let showsEditControls: Bool
    }

    var onTapBack: (() -> Void)?
    var onTapEdit: (() -> Void)?
    var onTapClearAll: (() -> Void)?

    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        config.baseForegroundColor = DSColors.textPrimary
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = DSColors.surface
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = DSColors.border.cgColor
        button.accessibilityLabel = "Voltar"
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .dsFonts(.poppinsBold24)
        label.textColor = DSColors.textPrimary
        label.text = "Favoritos"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .dsFonts(.poppinsRegular14)
        label.textColor = DSColors.textMuted
        label.numberOfLines = 2
        return label
    }()

    private lazy var editButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Editar"
        config.baseBackgroundColor = DSColors.surface
        config.baseForegroundColor = DSColors.accentSecondary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        return button
    }()

    private lazy var clearButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Limpar"
        config.baseForegroundColor = DSColors.textTertiary
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapClearAll), for: .touchUpInside)
        return button
    }()

    private let actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = DSSpacing.xs
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ viewModel: ViewModel) {
        if viewModel.countLabel.isEmpty {
            subtitleLabel.text = "Seus títulos salvos em um só lugar"
        } else {
            subtitleLabel.text = "Seus títulos salvos · \(viewModel.countLabel)"
        }

        editButton.isHidden = !viewModel.showsEditControls
        clearButton.isHidden = !viewModel.isEditing

        var editConfig = editButton.configuration
        editConfig?.title = viewModel.isEditing ? "Concluir" : "Editar"
        editConfig?.baseBackgroundColor = viewModel.isEditing
            ? DSColors.accentSecondary.withAlphaComponent(0.22)
            : DSColors.surface
        editConfig?.baseForegroundColor = viewModel.isEditing ? DSColors.textPrimary : DSColors.accentSecondary
        editButton.configuration = editConfig
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        actionsStack.addArrangedSubview(clearButton)
        actionsStack.addArrangedSubview(editButton)

        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(actionsStack)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            actionsStack.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            actionsStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: DSSpacing.md),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionsStack.leadingAnchor, constant: -DSSpacing.sm),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DSSpacing.xxs),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func didTapBack() { onTapBack?() }
    @objc private func didTapEdit() { onTapEdit?() }
    @objc private func didTapClearAll() { onTapClearAll?() }
}
