//
//  SplashContentView.swift
//  TMDB Movie
//

import UIKit

/// Conteúdo principal da Splash: logo, textos, skip e hint.
final class SplashContentView: UIView {

    var onSkipTapped: (() -> Void)?

    var entranceAnimationViews: [UIView] {
        [titleImageView, titleLabel, taglineLabel, skipButton, hintLabel]
    }

    var hintTopAnchor: NSLayoutYAxisAnchor { hintLabel.topAnchor }

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pular", for: .normal)
        button.setTitleColor(DSColors.textSecondary, for: .normal)
        button.titleLabel?.font = .dsFonts(.poppinsBold14)
        button.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        return button
    }()

    private lazy var titleImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "TitleImage")
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Filmes, séries e animes em um só lugar."
        label.font = .dsFonts(.poppinsBold30)
        label.textColor = DSColors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private lazy var taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tendências da semana, recomendações e favoritos — com visual de streaming."
        label.font = .dsFonts(.poppinsRegular15)
        label.textColor = DSColors.textHighlight
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Toque na tela para entrar"
        label.font = .dsFonts(.poppinsRegular14)
        label.textColor = DSColors.textSubtle
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
        applyTaglineStyle()
    }

    required init?(coder: NSCoder) { nil }

    func applyTaglineStyle() {
        guard let text = taglineLabel.text else { return }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.16
        paragraph.paragraphSpacing = 2

        taglineLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: DSColors.textHighlight,
                .kern: 0.12,
                .paragraphStyle: paragraph,
                .font: UIFont.dsFonts(.poppinsRegular15)
            ]
        )
    }

    func setHintVisible(_ visible: Bool, animated: Bool) {
        let changes = { self.hintLabel.alpha = visible ? 1 : 0 }
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations: changes)
        } else {
            changes()
        }
    }

    func prepareForEntranceAnimation() {
        for view in entranceAnimationViews {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 16)
        }
    }

    func entranceAlpha(for view: UIView, showHint: Bool) -> CGFloat {
        if view === hintLabel { return showHint ? 1 : 0 }
        return 1
    }

    // MARK: - Private

    @objc private func didTapSkip() {
        onSkipTapped?()
    }
}

extension SplashContentView: ViewCodeType {

    func buildViewHierarchy() {
        addSubview(skipButton)
        addSubview(titleImageView)
        addSubview(titleLabel)
        addSubview(taglineLabel)
        addSubview(hintLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            skipButton.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleImageView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 20),
            titleImageView.widthAnchor.constraint(equalToConstant: 118),
            titleImageView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 12),

            taglineLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            taglineLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),

            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
