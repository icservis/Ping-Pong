//
//  GameResult.swift
//  ping-pong
//
//  Created by Libor Kučera on 23.06.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

struct GameResult {
    var level: Player.Difficulty
    var score: Player.Score
    var time: ElapsedTime

    init(level: Player.Difficulty, score: Player.Score, time: ElapsedTime) {
        self.level = level
        self.score = score
        self.time = time
    }

    init() {
        self.level = .easy
        self.score = (player: 0, enemy: 0)
        self.time = ElapsedTime()
    }
}
