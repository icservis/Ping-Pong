//
//  Localizer.swift
//  ping-pong
//
//  Created by Libor Kučera on 30.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

final class Localizer {
    static let shared: Localizer = Localizer()

    func localize(_ string: String) -> String {
        return string
    }
}

extension String {
    func localize() -> String {
        return Localizer.shared.localize(self)
    }
}
