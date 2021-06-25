//
//  UIColor+Extensions.swift
//  ping-pong
//
//  Created by Libor Kučera on 01.02.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

extension UIColor {
    static let appBlack: UIColor = .black
    static let appOrange: UIColor = .orange
    static let appSilver: UIColor = .gray
    static let appWhite: UIColor = .white

    struct MainMenu {
        static let labelText: UIColor = appBlack
        static let buttonText: UIColor = appBlack
        static let border: UIColor = appSilver
        static let background: UIColor = appWhite
    }

    struct PauseMenu {
        static let labelText: UIColor = appBlack
        static let buttonText: UIColor = appBlack
        static let border: UIColor = appSilver
        static let background: UIColor = appWhite
    }

    struct GameOver {
        static let labelText: UIColor = appBlack
        static let altLabelText: UIColor = appOrange
        static let buttonText: UIColor = appBlack
        static let border: UIColor = appSilver
        static let background: UIColor = appWhite
    }
}
