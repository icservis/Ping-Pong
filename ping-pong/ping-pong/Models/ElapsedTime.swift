//
//  ElapsedTime.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.06.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

final class ElapsedTime: NSObject {
    typealias Time = TimeInterval

    static let limit: Time = 3_600
    private(set) var limit: Time

    static let delta: Time = 0.1
    private(set) var delta: Time

    typealias TimeChangedBlock = (Time) -> Void
    var timeChangedBlock: TimeChangedBlock?

    private(set) var time: Time {
        didSet {
            timeChangedBlock?(time)
        }
    }

    typealias TimeOverChangedBlock = (Time) -> Void
    var timeOverBlock: TimeOverChangedBlock?
    var isOver: Bool {
        return self.time > self.limit
    }

    init(time: Time, limit: Time, delta: Time) {
        self.time = time
        self.limit = limit
        self.delta = delta
    }

    override convenience init() {
        self.init(time: 0, limit: Self.limit, delta: Self.delta)
    }

    func update(completion: TimeOverChangedBlock?) {
        self.time += self.delta
        guard self.isOver else { return }
        completion?(self.time)
    }

    func reset() {
        self.time = 0
    }

    func string() -> String? {
        self.time.toString(precision: .deciseconds)
    }

    func score(multiplier: Double = 100) -> Int {
        let scoreValue: Double = self.time * multiplier
        return Int(round(scoreValue))
    }
}
