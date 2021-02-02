//
//  NumberFormatter+Extensions.swift
//  ping-pong
//
//  Created by Libor Kučera on 02.02.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

extension NumberFormatter {
    open func string(from timeInterval: TimeInterval) -> String? {
        let number = NSNumber(value: timeInterval)
        return self.string(from: number)
    }
}
