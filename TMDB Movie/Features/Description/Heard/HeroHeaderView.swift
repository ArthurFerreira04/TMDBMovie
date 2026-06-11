//
//  HeroHeaderView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class HeroHeaderView: UIView {

    struct ViewModel {
        let image: UIImage?
        let isFavorite: Bool
    }

    var onTapBack: (() -> Void)?
    var onTapFavorite: (() -> Void)?

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let overlayView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        return v
    }()

    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.baseForegroundColor = DSColors.textPrimary
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = DSColors.overlayScrimLight
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        return b
    }()

    private let backLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Voltar"
        l.font = .dsFonts(.poppinsBold14)
        l.textColor = DSColors.textPrimary
        return l
    }()

    private let favoriteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = DSColors.overlayButton
        config.baseForegroundColor = DSColors.textPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let topBar: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 8
        return s
    }()

    private let spacer = UIView()
    private var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = overlayView.bounds
    }

    func configure(_ viewModel: ViewModel) {
        imageView.image = viewModel.image
        applyFavorite(isFavorite: viewModel.isFavorite)
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        addSubview(imageView)
        addSubview(overlayView)
        addSubview(topBar)

        topBar.addArrangedSubview(backButton)
        topBar.addArrangedSubview(backLabel)
        topBar.addArrangedSubview(spacer)
        topBar.addArrangedSubview(favoriteButton)

        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: DSSpacing.xs),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSSpacing.screenHorizontal),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.screenHorizontal)
        ])

        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)

        applyGradient()
        applyFavorite(isFavorite: false)
    }

    private func applyGradient() {
        let g = CAGradientLayer()
        g.colors = [
            DSColors.heroOverlayTop.cgColor,
            DSColors.heroOverlayMid.cgColor,
            DSColors.heroOverlayBottom.cgColor
        ]
        g.locations = [0.0, 0.55, 1.0]
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint = CGPoint(x: 0.5, y: 1.0)

        overlayView.layer.insertSublayer(g, at: 0)
        gradientLayer = g
    }

    private func applyFavorite(isFavorite: Bool) {
        let name = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func didTapBack() {
        onTapBack?()
    }

    @objc private func didTapFavorite() {
        onTapFavorite?()
    }
}
