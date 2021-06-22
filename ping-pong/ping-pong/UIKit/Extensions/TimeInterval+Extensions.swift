//
//  TimeInterval+Extensions.swift
//  ping-pong
//
//  Created by Libor Kučera on 22.06.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

extension TimeInterval {

    enum Precision {
        case hours, minutes, seconds, deciseconds, centiseconds, miliseconds
    }

    func toString(precision: Precision) -> String? {
        guard self > 0 && self < Double.infinity else {
            return "0"
        }

        let time = NSInteger(self)

        let miliseconds  = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let centiseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        let deciseconds  = Int((self.truncatingRemainder(dividingBy: 1)) * 10)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours   = (time / 3600)

        switch precision {
        case .hours:
            return String(format: "%0.2d", hours)
        case .minutes:
            if hours > 10 {
                return String(format: "%0.2d:%0.2d", hours, minutes)
            } else if hours > 0 {
                return String(format: "%0.1d:%0.2d", hours, minutes)
            } else {
                return String(format: "%0.2d", minutes)
            }
        case .seconds:
            if hours > 10 {
                return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
            } else if hours > 0 {
                return String(format: "%0.1d:%0.2d:%0.2d", hours, minutes, seconds)
            } else if minutes > 0 {
                return String(format: "%0.2d:%0.2d", minutes, seconds)
            } else {
                return String(format: "%0.2d", seconds)
            }
        case .deciseconds:
            if hours > 10 {
                return String(format: "%0.2d:%0.2d:%0.2d.%0.1d", hours, minutes, seconds, deciseconds)
            } else if hours > 0 {
                return String(format: "%0.1d:%0.2d:%0.2d.%0.1d", hours, minutes, seconds, deciseconds)
            } else if minutes > 0 {
                return String(format: "%0.2d:%0.2d.%0.1d", minutes, seconds, deciseconds)
            } else {
                return String(format: "%0.2d.%0.1d", seconds, deciseconds)
            }
        case .centiseconds:
            if hours > 10 {
                return String(format: "%0.2d:%0.2d:%0.2d.%0.2d", hours, minutes, seconds, centiseconds)
            } else if hours > 0 {
                return String(format: "%0.1d:%0.2d:%0.2d.%0.2d", hours, minutes, seconds, centiseconds)
            } else if minutes > 0 {
                return String(format: "%0.2d:%0.2d.%0.2d", minutes, seconds, centiseconds)
            } else {
                return String(format: "%0.2d.%0.2d", seconds, centiseconds)
            }
        case .miliseconds:
            if hours > 10 {
                return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, miliseconds)
            } else if hours > 0 {
                return String(format: "%0.1d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, miliseconds)
            } else if minutes > 0 {
                return String(format: "%0.2d:%0.2d.%0.3d", minutes, seconds, miliseconds)
            } else {
                return String(format: "%0.2d.%0.3d", seconds, miliseconds)
            }
        }
    }
}
