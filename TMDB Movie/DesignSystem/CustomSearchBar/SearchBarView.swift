//
//  SearchBarView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 07/01/26.
//

import UIKit

final class SearchBarView: UIView, UITextFieldDelegate {

    struct ViewModel {
        let placeholder: String
        let text: String?
        let isSearchEnabled: Bool

        init(
            placeholder: String,
            text: String? = nil,
            isSearchEnabled: Bool = true
        ) {
            self.placeholder = placeholder
            self.text = text
            self.isSearchEnabled = isSearchEnabled
        }
    }

    var onSearch: ((String) -> Void)?
    var onTextChange: ((String) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = DSColors.border.cgColor
        view.backgroundColor = DSColors.overlayLight
        return view
    }()

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = DSColors.textSecondary
        return view
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.textColor = DSColors.textInput
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.returnKeyType = .search
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.clearButtonMode = .whileEditing
        tf.accessibilityLabel = "Buscar"
        return tf
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ viewModel: ViewModel) {
        textField.placeholder = viewModel.placeholder
        textField.text = viewModel.text
        setSearchEnabled(viewModel.isSearchEnabled)
        updatePlaceholderStyle()
    }

    func setText(_ text: String) {
        textField.text = text
    }

    func setSearchEnabled(_ enabled: Bool) {
        textField.isEnabled = enabled
        alpha = enabled ? 1.0 : 0.6
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(textField)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 48),

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DSSpacing.md),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DSSpacing.sm),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DSSpacing.md),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        accessibilityElements = [textField]
        updatePlaceholderStyle()
    }

    private func updatePlaceholderStyle() {
        guard let placeholder = textField.placeholder else { return }
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: DSColors.textPlaceholder,
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
    }

    @objc private func textDidChange() {
        onTextChange?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSearch?((textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
        textField.resignFirstResponder()
        return true
    }
}
