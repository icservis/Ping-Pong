//
//  UIFont+Extensions.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

extension UIFont {
    enum CustomFontFamily: String {
        case llPixel3 = "LLPIXEL3.ttf"
    }

    static func scaledLabelFont(for family: CustomFontFamily) -> UIFont {
        guard let customFontFamily = UIFont(name: family.rawValue, size: UIFont.labelFontSize) else {
            fatalError("Cannot instantiate font family")
        }
        return UIFontMetrics.default.scaledFont(for: customFontFamily)
    }

    static func scaledButtonFont(for family: CustomFontFamily) -> UIFont {
        guard let customFontFamily = UIFont(name: family.rawValue, size: UIFont.buttonFontSize) else {
            fatalError("Cannot instantiate font family")
        }
        return UIFontMetrics.default.scaledFont(for: customFontFamily)
    }

    static func scaledSmallSystemFont(for family: CustomFontFamily) -> UIFont {
        guard let customFontFamily = UIFont(name: family.rawValue, size: UIFont.smallSystemFontSize) else {
            fatalError("Cannot instantiate font family")
        }
        return UIFontMetrics.default.scaledFont(for: customFontFamily)
    }

    static func scaledSystemFont(for family: CustomFontFamily) -> UIFont {
        guard let customFontFamily = UIFont(name: family.rawValue, size: UIFont.systemFontSize) else {
            fatalError("Cannot instantiate font family")
        }
        return UIFontMetrics.default.scaledFont(for: customFontFamily)
    }
}
