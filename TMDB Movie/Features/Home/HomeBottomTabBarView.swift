//
//  HomeBottomTabBarView.swift
//  TMDB Movie
//

import UIKit

protocol HomeBottomTabBarViewDelegate: AnyObject {
    func homeBottomTabBarDidSelectHome(_ tabBar: HomeBottomTabBarView)
    func homeBottomTabBarDidSelectFavorites(_ tabBar: HomeBottomTabBarView)
}

final class HomeBottomTabBarView: UIView {

    weak var delegate: HomeBottomTabBarViewDelegate?

    private(set) var isHomeSelected = true

    private let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = DSColors.border.cgColor
        view.backgroundColor = DSColors.surfaceCard
        return view
    }()

    private let selectionPill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 16
        view.backgroundColor = DSColors.surface
        return view
    }()

    private let tabStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    private var selectionLeadingConstraint: NSLayoutConstraint?
    private let selectionHaptic = UISelectionFeedbackGenerator()

    private lazy var homeTabButton: UIButton = makeTabButton(
        title: "Início",
        systemImage: "house.fill",
        action: #selector(didTapHome)
    )

    private lazy var favoritesTabButton: UIButton = makeTabButton(
        title: "Favoritos",
        systemImage: "heart.fill",
        action: #selector(didTapFavorites)
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        selectionHaptic.prepare()
        setupLayout()
        setSelected(isHome: true, animated: false)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }

    func setSelected(isHome: Bool, animated: Bool) {
        isHomeSelected = isHome
        updateTabAppearance()
        moveSelectionPill(animated: animated)
        animateSelection(isHome: isHome)
    }

    func prepareForReuseOnAppear() {
        setSelected(isHome: true, animated: false)
    }

    private func setupLayout() {
        addSubview(blurView)
        blurView.contentView.addSubview(highlightView)
        blurView.contentView.addSubview(selectionPill)
        blurView.contentView.addSubview(tabStackView)
        tabStackView.addArrangedSubview(homeTabButton)
        tabStackView.addArrangedSubview(favoritesTabButton)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 72),

            highlightView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            highlightView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            highlightView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),

            tabStackView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 6),
            tabStackView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -6),
            tabStackView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 6),
            tabStackView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -6),

            selectionPill.topAnchor.constraint(equalTo: tabStackView.topAnchor, constant: 4),
            selectionPill.bottomAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: -4),
            selectionPill.widthAnchor.constraint(equalTo: tabStackView.widthAnchor, multiplier: 0.5, constant: -5)
        ])

        selectionLeadingConstraint = selectionPill.leadingAnchor.constraint(
            equalTo: tabStackView.leadingAnchor,
            constant: 6
        )
        selectionLeadingConstraint?.isActive = true
    }

    private func makeTabButton(title: String, systemImage: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: systemImage)
        config.imagePlacement = .top
        config.imagePadding = 4
        config.baseForegroundColor = DSColors.textSecondary
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var out = attrs
            out.font = .dsFonts(.poppinsBold12)
            return out
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func updateTabAppearance() {
        updateTabButton(
            homeTabButton,
            isSelected: isHomeSelected,
            selectedSymbol: "house.fill",
            normalSymbol: "house"
        )
        updateTabButton(
            favoritesTabButton,
            isSelected: !isHomeSelected,
            selectedSymbol: "heart.fill",
            normalSymbol: "heart"
        )
    }

    private func updateTabButton(
        _ button: UIButton,
        isSelected: Bool,
        selectedSymbol: String,
        normalSymbol: String
    ) {
        button.configuration?.baseForegroundColor = isSelected ? DSColors.textPrimary : DSColors.textSecondary
        button.configuration?.image = UIImage(systemName: isSelected ? selectedSymbol : normalSymbol)
    }

    @objc private func didTapHome() {
        if isHomeSelected {
            delegate?.homeBottomTabBarDidSelectHome(self)
            return
        }
        selectionHaptic.selectionChanged()
        setSelected(isHome: true, animated: true)
        delegate?.homeBottomTabBarDidSelectHome(self)
    }

    @objc private func didTapFavorites() {
        guard isHomeSelected else { return }
        selectionHaptic.selectionChanged()
        setSelected(isHome: false, animated: true)
        delegate?.homeBottomTabBarDidSelectFavorites(self)
    }

    private func moveSelectionPill(animated: Bool) {
        let targetX: CGFloat = isHomeSelected ? 6 : (tabStackView.bounds.width / 2) + 1
        selectionLeadingConstraint?.constant = targetX
        let changes = { self.blurView.layoutIfNeeded() }
        if animated {
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.25,
                options: [.curveEaseInOut]
            ) {
                changes()
            }
        } else {
            changes()
        }
    }

    private func animateSelection(isHome: Bool) {
        let selectedButton = isHome ? homeTabButton : favoritesTabButton
        let nonSelectedButton = isHome ? favoritesTabButton : homeTabButton

        selectedButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        nonSelectedButton.transform = .identity

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            selectedButton.transform = .identity
            nonSelectedButton.alpha = 1.0
        }
    }

    private func updateShadowPath() {
        blurView.layer.shadowColor = DSColors.shadow.cgColor
        blurView.layer.shadowOpacity = 0.25
        blurView.layer.shadowRadius = 14
        blurView.layer.shadowOffset = CGSize(width: 0, height: 8)
        blurView.layer.shadowPath = UIBezierPath(
            roundedRect: blurView.bounds,
            cornerRadius: blurView.layer.cornerRadius
        ).cgPath
    }
}
