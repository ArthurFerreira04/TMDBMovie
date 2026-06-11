//
//  TitleSummaryView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class TitleSummaryView: UIView {

    struct ViewModel: Equatable {
        let ratingPercent: Int
        let title: String
        let meta: String
    }

    private let ringView = ProgressRingView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DSColors.textPrimary
        label.font = .dsFonts(.poppinsBold24)
        label.numberOfLines = 2
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.textColor = DSColors.textSecondary
        label.font = .dsFonts(.poppinsRegular14)
        label.numberOfLines = 2
        return label
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = DSSpacing.sm
        return stack
    }()

    private let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = DSSpacing.md
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ viewModel: ViewModel) {
        ringView.setProgress(Double(viewModel.ratingPercent) / 100.0, text: "\(viewModel.ratingPercent)%")
        titleLabel.text = viewModel.title
        metaLabel.text = viewModel.meta
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(metaLabel)

        rowStack.addArrangedSubview(ringView)
        rowStack.addArrangedSubview(textStack)

        addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            ringView.widthAnchor.constraint(equalToConstant: 60),
            ringView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
