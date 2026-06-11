//
//  DSColors.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import Foundation
import UIKit

public enum Colors: String {

    case grayligth = "#F5F5F5"
    case gray = "#707070"
    case purple = "#8000FF"
    case pink = "#FF1F8A"
}

public extension UIColor {
    static func ds(_ color: Colors) -> UIColor {
        UIColor(hexString: color.rawValue)
    }
}

/// Tokens semânticos — centraliza alphas e cores repetidas na UI.
enum DSColors {
    // Text
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor.white.withAlphaComponent(0.72)
    static let textTertiary = UIColor.white.withAlphaComponent(0.55)
    static let textMuted = UIColor.white.withAlphaComponent(0.68)
    static let textSubtle = UIColor.white.withAlphaComponent(0.62)
    static let textHighlight = UIColor.white.withAlphaComponent(0.82)
    static let textEmphasis = UIColor.white.withAlphaComponent(0.86)
    static let textInput = UIColor.white.withAlphaComponent(0.95)
    static let textPlaceholder = UIColor.white.withAlphaComponent(0.42)
    static let textStatus = UIColor.white.withAlphaComponent(0.78)
    static let iconPrimary = UIColor.white.withAlphaComponent(0.90)

    // Surfaces
    static let background = UIColor.black
    static let surface = UIColor.white.withAlphaComponent(0.10)
    static let surfaceCard = UIColor.white.withAlphaComponent(0.04)
    static let surfaceSubtle = UIColor.white.withAlphaComponent(0.06)
    static let surfaceInset = UIColor.white.withAlphaComponent(0.07)
    static let overlayLight = UIColor.white.withAlphaComponent(0.08)
    static let track = UIColor.white.withAlphaComponent(0.18)

    // Borders & separators
    static let border = UIColor.white.withAlphaComponent(0.14)
    static let borderSubtle = UIColor.white.withAlphaComponent(0.10)
    static let separator = UIColor.white.withAlphaComponent(0.12)

    // Overlays
    static let overlayDark = UIColor.black.withAlphaComponent(0.45)
    static let overlayScrim = UIColor.black.withAlphaComponent(0.35)
    static let overlayScrimLight = UIColor.black.withAlphaComponent(0.22)
    static let overlayButton = UIColor.black.withAlphaComponent(0.26)
    static let overlayCarousel = UIColor.black.withAlphaComponent(0.22)
    static let heroOverlayTop = UIColor.black.withAlphaComponent(0.10)
    static let heroOverlayMid = UIColor.black.withAlphaComponent(0.55)
    static let heroOverlayBottom = UIColor.black.withAlphaComponent(0.90)
    static let gradientFadeBottom = UIColor.black.withAlphaComponent(0.85)
    static let gradientMidnight = UIColor(red: 18 / 255, green: 10 / 255, blue: 35 / 255, alpha: 1)

    // Accents & feedback
    static let accent = UIColor.ds(.purple)
    static let accentSecondary = UIColor.ds(.pink)
    static let accentBorder = UIColor.ds(.grayligth)
    static let success = UIColor.ds(.purple)
    static let error = UIColor.ds(.pink)

    // Effects
    static let shadow = UIColor.black
}

/// Escala de espaçamento (grid 8pt) — única fonte de verdade para margens e gaps.
enum DSSpacing {
    static let unit: CGFloat = 8

    static let xxs: CGFloat = unit * 0.5  // 4
    static let xs: CGFloat = unit         // 8
    static let sm: CGFloat = unit * 1.5   // 12
    static let md: CGFloat = unit * 2     // 16
    static let lg: CGFloat = unit * 3     // 24
    static let xl: CGFloat = unit * 4     // 32
    static let xxl: CGFloat = unit * 5    // 40

    static let screenHorizontal: CGFloat = lg
    static let sectionVertical: CGFloat = lg
}
