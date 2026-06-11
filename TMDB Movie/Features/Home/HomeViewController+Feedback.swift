//
//  HomeViewController+Feedback.swift
//  TMDB Movie
//

import UIKit

extension HomeViewController {

    func applyFeedback(
        for state: HomeViewModel.ViewState,
        using feedbackView: DSFeedbackView,
        onRetry: @escaping () -> Void
    ) {
        switch state.status {
        case .idle, .loading, .loaded:
            feedbackView.apply(.hidden)
        case .empty:
            let isSearch = state.sections.contains { $0.type.isSearch }
            if isSearch {
                feedbackView.apply(.empty(
                    title: "Nenhum resultado",
                    message: "Tente outro termo ou explore as categorias.",
                    actionTitle: nil
                ))
            } else {
                feedbackView.apply(.empty(
                    title: "Sem títulos",
                    message: "Não encontramos conteúdo para exibir agora.",
                    actionTitle: "Recarregar"
                ))
                feedbackView.onAction = onRetry
            }
        case .error(let message):
            feedbackView.apply(.error(message: message, actionTitle: "Tentar novamente"))
            feedbackView.onAction = onRetry
        }
    }
}
