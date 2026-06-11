//
//  SplashMotionEffectsConfigurator.swift
//  TMDB Movie
//

import UIKit

enum SplashMotionEffectsConfigurator {

    static func apply(
        heroBackground: SplashHeroBackgroundView,
        contentContainer: UIView
    ) {
        heroBackground.addMotionEffectToSlideshow(makeBackgroundParallax())
        contentContainer.addMotionEffect(makeContentParallax())
    }

    private static func makeBackgroundParallax() -> UIMotionEffectGroup {
        let group = UIMotionEffectGroup()
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -10
        horizontal.maximumRelativeValue = 10
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -8
        vertical.maximumRelativeValue = 8
        group.motionEffects = [horizontal, vertical]
        return group
    }

    private static func makeContentParallax() -> UIMotionEffectGroup {
        let group = UIMotionEffectGroup()
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = 4
        horizontal.maximumRelativeValue = -4
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = 3
        vertical.maximumRelativeValue = -3
        group.motionEffects = [horizontal, vertical]
        return group
    }
}
