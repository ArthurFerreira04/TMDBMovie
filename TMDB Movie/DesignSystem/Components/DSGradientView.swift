//
//  DSGradientView.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import UIKit

public final class DSGradientView: UIView {

    public var style: DSGradientStyle = .heroPoster {
        didSet { setNeedsLayout() }
    }

    public override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = style.colors
        gradient.locations = style.locations
        gradient.startPoint = style.startPoint
        gradient.endPoint = style.endPoint
    }
}
