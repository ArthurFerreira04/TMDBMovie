//
//  ProgressRingView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class ProgressRingView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = DSColors.textPrimary
        l.font = .dsFonts(.poppinsBold12)
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        let lineWidth: CGFloat = 6
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let start = -CGFloat.pi / 2
        let end = start + 2 * CGFloat.pi
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)

        [trackLayer, progressLayer].forEach {
            $0.frame = bounds
            $0.path = path.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.lineWidth = lineWidth
            $0.lineCap = .round
        }
    }

    func setProgress(_ progress: Double, text: String) {
        progressLayer.strokeEnd = max(0, min(1, progress))
        label.text = text
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        trackLayer.strokeColor = DSColors.track.cgColor
        trackLayer.strokeEnd = 1

        progressLayer.strokeColor = DSColors.accentSecondary.cgColor
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)

        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
