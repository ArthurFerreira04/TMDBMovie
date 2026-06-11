//
//  SplashHeroBackgroundView.swift
//  TMDB Movie
//

import UIKit

/// Background cinematográfico da Splash: slideshow remoto + gradientes.
final class SplashHeroBackgroundView: UIView {

    private let slideshowView = RemoteImageSlideshowView()

    private lazy var topGradientView: DSGradientView = {
        let view = DSGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .heroPoster
        return view
    }()

    private lazy var bottomGradientView: DSGradientView = {
        let view = DSGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .heroPoster
        view.alpha = 0.92
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        setupView()
    }

    required init?(coder: NSCoder) { nil }

    func configure(urls: [URL], imageLoader: ImageLoaderProtocol, interval: TimeInterval = 4.2) {
        slideshowView.configure(urls: urls, imageLoader: imageLoader, interval: interval)
        slideshowView.start()
    }

    func start() {
        slideshowView.start()
    }

    func stop() {
        slideshowView.stop()
    }

    func addMotionEffectToSlideshow(_ effect: UIMotionEffect) {
        slideshowView.addMotionEffect(effect)
    }

    func animateBottomGradientEntrance() {
        bottomGradientView.alpha = 0.5
        UIView.animate(withDuration: 0.65, delay: 0, options: [.curveEaseOut]) {
            self.bottomGradientView.alpha = 0.92
        }
    }
}

extension SplashHeroBackgroundView: ViewCodeType {

    func buildViewHierarchy() {
        addSubview(slideshowView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
    }

    func setupConstraints() {
        slideshowView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor
        )

        topGradientView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor
        )

        bottomGradientView.anchor(
            top: centerYAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor
        )
    }
}
