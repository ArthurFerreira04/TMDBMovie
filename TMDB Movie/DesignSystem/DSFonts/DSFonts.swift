//
//  DSFonts.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import Foundation
import UIKit

public enum DSFonts {
    case poppinsBold30
    case poppinsBold24
    case poppinsBold21
    case poppinsBold20
    case poppinsRegular20
    case poppinsRegular12
    case poppinsBold12
    case poppinsBold14
    case poppinsRegular14
    case poppinsBold10
    case poppinsRegular10
    case poppinsBold15
    case poppinsRegular15
    case poppinsBold18
    case poppinsRegular18
    case poppinsBold16
    case poppinsRegular16
}

public extension UIFont {
    static func dsFonts( _ font: DSFonts) -> UIFont {
        let fontDefalt: UIFont = systemFont(ofSize: 14)
        switch font {
        case.poppinsBold30:
            return UIFont(name: "Poppins-Bold", size: 30) ?? fontDefalt
        case.poppinsBold21:
            return UIFont(name: "Poppins-Bold", size: 21) ?? fontDefalt
        case.poppinsBold24:
            return UIFont(name: "Poppins-Bold", size: 24) ?? fontDefalt
        case.poppinsBold20:
            return UIFont(name: "Poppins-Bold", size: 20) ?? fontDefalt
        case.poppinsRegular20:
            return UIFont(name: "Poppins-Regular", size: 20) ?? fontDefalt
        case.poppinsRegular12:
            return UIFont(name: "Poppins-Regular", size: 12) ?? fontDefalt
        case.poppinsBold14:
            return UIFont(name: "Poppins-Bold", size: 14) ?? fontDefalt
        case.poppinsBold12:
            return UIFont(name: "Poppins-Bold", size: 12) ?? fontDefalt
        case.poppinsRegular14:
            return UIFont(name: "Poppins-Regular", size: 14) ?? fontDefalt
        case.poppinsBold15:
            return UIFont(name: "Poppins-Bold", size: 15) ?? fontDefalt
        case.poppinsRegular15:
            return UIFont(name: "Poppins-Regular", size: 15) ?? fontDefalt
        case.poppinsBold16:
            return UIFont(name: "Poppins-Bold", size: 16) ?? fontDefalt
        case.poppinsRegular16:
            return UIFont(name: "Poppins-Regular", size: 16) ?? fontDefalt
        case.poppinsRegular18:
            return UIFont(name: "Poppins-Regular", size: 18) ?? fontDefalt
        case.poppinsBold18:
            return UIFont(name: "Poppins-Bold", size: 18) ?? fontDefalt
        case.poppinsBold10:
            return UIFont(name: "Poppins-Bold", size: 10) ?? fontDefalt
        case.poppinsRegular10:
            return UIFont(name: "Poppins-Regular", size: 10) ?? fontDefalt
        }
    }
}

