//
//  RemoteImageSlideshowView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 09/01/26.
//

import UIKit

final class RemoteImageSlideshowView: UIView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private var urls: [URL] = []
    private var index: Int = 0

    private var timer: Timer?
    private var interval: TimeInterval = 4.0

    private var imageLoader: ImageLoaderProtocol?
    private var loadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        stop()
    }

    func configure(urls: [URL], imageLoader: ImageLoaderProtocol, interval: TimeInterval = 4.0) {
        self.urls = urls
        self.imageLoader = imageLoader
        self.interval = interval
        self.index = 0
        loadFirst()
    }

    func start() {
        stopTimerOnly()
        guard urls.count > 1 else { return }

        let t = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.showNext()
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    func stop() {
        stopTimerOnly()
        loadTask?.cancel()
        loadTask = nil
    }

    private func stopTimerOnly() {
        timer?.invalidate()
        timer = nil
    }

    private func loadFirst() {
        imageView.image = UIImage(named: "Splash")
        guard let first = urls.first, let loader = imageLoader else { return }
        load(url: first, loader: loader, animated: false)
    }

    private func showNext() {
        guard !urls.isEmpty, let loader = imageLoader else { return }
        index = (index + 1) % urls.count
        load(url: urls[index], loader: loader, animated: true)
    }

    private func load(url: URL, loader: ImageLoaderProtocol, animated: Bool) {
        loadTask?.cancel()

        loadTask = Task { [weak self] in
            guard let self else { return }
            guard let image = try? await loader.load(url) else { return }

            await MainActor.run {
                if animated {
                    UIView.transition(
                        with: self.imageView,
                        duration: 0.35,
                        options: [.transitionCrossDissolve, .allowUserInteraction]
                    ) {
                        self.imageView.image = image
                    }
                } else {
                    self.imageView.image = image
                }
            }
        }
    }
}
