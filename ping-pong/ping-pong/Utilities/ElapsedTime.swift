//
//  ElapsedTime.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.06.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

final class ElapsedTime: NSObject {
    typealias Value = TimeInterval
    typealias ValueChangedBlock = (Value) -> Void
    static let delta: Value = 0.1

    var value: Value {
        didSet {
            valueChangedBlock?(value)
        }
    }
    var valueChangedBlock: ValueChangedBlock?

    init(value: Value) {
        self.value = value
    }

    override convenience init() {
        self.init(value: 0)
    }

    func update(with delta: Value) {
        self.value += delta
    }

    func reset() {
        self.value = 0
    }

    lazy var elapsedTimeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.allowsFloats = true

        return formatter
    }()

    func string() -> String? {
        self.elapsedTimeFormatter.string(from: self.value)
    }

    class func string(for value: Value) -> String? {
        let elapsedTime = ElapsedTime(value: value)
        return elapsedTime.string()
    }

    func score() -> Int {
        let scoreValue: Double = self.value * Double(100)
        return Int(round(scoreValue))
    }

    class func score(for value: Value) -> Int {
        let elapsedTime = ElapsedTime(value: value)
        return elapsedTime.score()
    }
}
