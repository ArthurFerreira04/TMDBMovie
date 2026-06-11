//
//  CustomButton.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import UIKit

final class CustomButton: UIButton {

    enum Style {
        case containedQuadPurple
        case borderButton
    }

    private let style: Style

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupButton()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var isEnabled: Bool {
        didSet { updateState() }
    }

    override var isHighlighted: Bool {
        didSet { updateState() }
    }

    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 6
        clipsToBounds = true
        titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        accessibilityTraits = .button
    }

    private func applyStyle() {
        switch style {
        case .containedQuadPurple:
            backgroundColor = DSColors.accent
            setTitleColor(DSColors.textPrimary, for: .normal)
            layer.borderWidth = 0
            layer.borderColor = nil

        case .borderButton:
            backgroundColor = .clear
            setTitleColor(DSColors.textPrimary, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = DSColors.accentBorder.cgColor
        }

        updateState()
    }

    private func updateState() {
        if !isEnabled {
            alpha = 0.4
            return
        }

        alpha = 1.0

        if isHighlighted {
            transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        } else {
            transform = .identity
        }
    }
}
