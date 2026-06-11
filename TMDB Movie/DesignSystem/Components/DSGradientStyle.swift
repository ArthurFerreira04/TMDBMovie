//
//  DSGradientStyle.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import UIKit

public struct DSGradientStyle {

    public let colors: [CGColor]
    public let locations: [NSNumber]
    public let startPoint: CGPoint
    public let endPoint: CGPoint

    public static let heroPoster = DSGradientStyle(
        colors: [
            UIColor.clear.cgColor,
            DSColors.gradientFadeBottom.cgColor
        ],
        locations: [0.35, 1.0],
        startPoint: CGPoint(x: 0.5, y: 0.0),
        endPoint: CGPoint(x: 0.5, y: 1.0)
    )
}

