//
//  SplashStatusView.swift
//  TMDB Movie
//

import UIKit

/// Bloco inferior de status: loading, mensagem de erro e retry.
final class SplashStatusView: UIView {

    var onRetryTapped: (() -> Void)?

    /// Usado pela animação de entrada da Splash.
    var entranceAnimationView: UIView { statusStack }

    private let statusStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = DSColors.textPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Preparando a experiência…"
        label.font = .dsFonts(.poppinsRegular14)
        label.textColor = DSColors.textStatus
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = DSColors.textStatus
        label.font = .dsFonts(.poppinsRegular14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    private lazy var retryButton: CustomButton = {
        let button = CustomButton(style: .containedQuadPurple)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tentar novamente", for: .normal)
        button.titleLabel?.font = .dsFonts(.poppinsBold14)
        button.layer.cornerRadius = 12
        button.alpha = 0
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return button
    }()

    private lazy var retryHeightConstraint: NSLayoutConstraint = {
        retryButton.heightAnchor.constraint(equalToConstant: 0)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        build()
    }

    required init?(coder: NSCoder) { nil }

    func render(_ state: SplashViewModel.State) {
        switch state {
        case .idle:
            showIdle()
        case .loading:
            showLoading()
        case .loaded:
            showLoaded()
        case .error(let message):
            showError(message: message)
        }
    }

    func prepareForRetry() {
        messageLabel.alpha = 0
        messageLabel.isHidden = true
        retryButton.alpha = 0
        retryHeightConstraint.constant = 0
    }

    // MARK: - Private

    private func build() {
        statusStack.addArrangedSubview(activityIndicator)
        statusStack.addArrangedSubview(statusLabel)

        addSubview(statusStack)
        addSubview(messageLabel)
        addSubview(retryButton)

        NSLayoutConstraint.activate([
            statusStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),

            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            retryButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            retryHeightConstraint,

            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -10),
            messageLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)
        ])
    }

    private func showIdle() {
        activityIndicator.stopAnimating()
        statusStack.isHidden = false
        statusLabel.text = "Preparando a experiência…"
        hideMessageAndRetry()
    }

    private func showLoading() {
        activityIndicator.startAnimating()
        statusStack.isHidden = false
        statusLabel.text = "Carregando destaques…"
        hideMessageAndRetry()
    }

    private func showLoaded() {
        activityIndicator.stopAnimating()
        statusStack.isHidden = true
        hideMessageAndRetry()
    }

    private func showError(message: String) {
        activityIndicator.stopAnimating()
        statusStack.isHidden = false
        statusLabel.text = "Algo deu errado"
        messageLabel.text = message
        messageLabel.isHidden = false
        messageLabel.alpha = 1
        retryHeightConstraint.constant = 48
        UIView.animate(withDuration: 0.25) {
            self.retryButton.alpha = 1
        }
    }

    private func hideMessageAndRetry() {
        messageLabel.alpha = 0
        messageLabel.isHidden = true
        retryButton.alpha = 0
        retryHeightConstraint.constant = 0
    }

    @objc private func didTapRetry() {
        onRetryTapped?()
    }
}
