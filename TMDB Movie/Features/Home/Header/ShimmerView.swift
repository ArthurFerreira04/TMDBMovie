//
//  ShimmerView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 13/01/26.
//

import UIKit

final class ShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = DSColors.overlayLight
        layer.cornerRadius = 18
        clipsToBounds = true

        gradientLayer.colors = [
            DSColors.surfaceSubtle.cgColor,
            DSColors.track.cgColor,
            DSColors.surfaceSubtle.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations  = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func start() {
        guard !isAnimating else { return }
        isAnimating = true

        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-1.0, -0.5, 0.0]
        anim.toValue = [1.0, 1.5, 2.0]
        anim.duration = 1.2
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        gradientLayer.add(anim, forKey: "shimmer")
    }

    func stop() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}
