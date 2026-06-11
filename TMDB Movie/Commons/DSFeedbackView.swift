//
//  DSFeedbackView.swift
//  TMDB Movie
//

import UIKit

/// Estado inline reutilizável (vazio, erro, carregamento leve).
final class DSFeedbackView: UIView {

    enum Content: Equatable {
        case hidden
        case loading(message: String)
        case empty(title: String, message: String, actionTitle: String?)
        case error(message: String, actionTitle: String)
    }

    var onAction: (() -> Void)?

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DSSpacing.md
        return stack
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColors.textPrimary.withAlphaComponent(0.88)
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .dsFonts(.poppinsBold24)
        label.textColor = DSColors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .dsFonts(.poppinsRegular15)
        label.textColor = DSColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButton: CustomButton = {
        let button = CustomButton(style: .containedQuadPurple)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .dsFonts(.poppinsBold14)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        return button
    }()

    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = DSColors.textPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    func apply(_ content: Content, animated: Bool = true) {
        let updates = { self.render(content) }
        guard animated else {
            updates()
            return
        }
        UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: updates)
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        alpha = 0

        addSubview(stack)
        stack.addArrangedSubview(spinner)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(actionButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])

        stack.setCustomSpacing(DSSpacing.sm, after: iconView)
    }

    private func render(_ content: Content) {
        switch content {
        case .hidden:
            isHidden = true
            alpha = 0
            spinner.stopAnimating()
        case .loading(let message):
            isHidden = false
            alpha = 1
            iconView.isHidden = true
            titleLabel.isHidden = true
            actionButton.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message
            spinner.isHidden = false
            spinner.startAnimating()
        case .empty(let title, let message, let actionTitle):
            isHidden = false
            alpha = 1
            spinner.stopAnimating()
            spinner.isHidden = true
            iconView.isHidden = false
            iconView.image = UIImage(systemName: "film.stack")
            titleLabel.isHidden = false
            titleLabel.text = title
            messageLabel.isHidden = false
            messageLabel.text = message
            configureAction(title: actionTitle)
        case .error(let message, let actionTitle):
            isHidden = false
            alpha = 1
            spinner.stopAnimating()
            spinner.isHidden = true
            iconView.isHidden = false
            iconView.image = UIImage(systemName: "wifi.exclamationmark")
            titleLabel.isHidden = false
            titleLabel.text = "Algo deu errado"
            messageLabel.isHidden = false
            messageLabel.text = message
            configureAction(title: actionTitle)
        }
    }

    private func configureAction(title: String?) {
        guard let title else {
            actionButton.isHidden = true
            return
        }
        actionButton.isHidden = false
        actionButton.setTitle(title, for: .normal)
    }

    @objc private func didTapAction() {
        onAction?()
    }
}
