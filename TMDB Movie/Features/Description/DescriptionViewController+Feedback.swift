//
//  DescriptionViewController+Feedback.swift
//  TMDB Movie
//

import UIKit

extension DescriptionViewController {

    func installFeedbackOverlay(on contentView: DescriptionView) -> DSFeedbackView {
        let feedbackOverlay = DSFeedbackView()
        feedbackOverlay.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(feedbackOverlay)
        NSLayoutConstraint.activate([
            feedbackOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DSSpacing.screenHorizontal),
            feedbackOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DSSpacing.screenHorizontal),
            feedbackOverlay.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        feedbackOverlay.apply(.hidden)
        return feedbackOverlay
    }

    func applyDetailFeedback(
        for state: DescriptionViewModel.State,
        contentView: DescriptionView,
        feedbackOverlay: DSFeedbackView,
        onRetry: @escaping () -> Void
    ) {
        switch state {
        case .idle:
            break

        case .loading:
            contentView.alpha = 0.35
            feedbackOverlay.apply(.loading(message: "Carregando detalhes…"))
            feedbackOverlay.onAction = nil

        case .error(let message):
            contentView.alpha = 0.35
            feedbackOverlay.apply(.error(message: message, actionTitle: "Tentar novamente"))
            feedbackOverlay.onAction = onRetry

        case .loaded:
            contentView.alpha = 1
            feedbackOverlay.apply(.hidden)
            feedbackOverlay.onAction = nil
        }
    }
}
