//
//  UIColor+Extension.swift
//  Rebanho
//
//  Created by Arthur Ferreira on 03/04/24.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        guard let color = UInt32(hex, radix: 16) else {
            self.init(white: 0, alpha: alpha)
            return
        }

        let mask = 0x000000FF
        let red = Int(color >> 16) & mask
        let green = Int(color >> 8) & mask
        let blue = Int(color) & mask
        let redProportion   = CGFloat(red) / 255.0
        let greenProportion = CGFloat(green) / 255.0
        let blueProportion  = CGFloat(blue) / 255.0
        self.init(red: redProportion, green: greenProportion, blue: blueProportion, alpha: alpha)
    }
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alph: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alph)
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        return String(format: "#%06x", rgb)
    }
}
