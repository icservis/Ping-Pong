//
//  Player.swift
//  ping-pong
//
//  Created by Libor Kučera on 10.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import Logging

class Player: NSObject, NSCoding {
    lazy var logger: Logger = {
        var logger = Logger(label: "com.ic-servis.ping-pong.player")
        logger.logLevel = .trace
        return logger
    }()

    enum Difficulty: Int, CaseIterable {
        case easy
        case medium
        case hard

        static func random<G: RandomNumberGenerator>(using generator: inout G) -> Difficulty {
            return Difficulty.allCases.randomElement(using: &generator)!
        }

        static func random() -> Difficulty {
            var g = SystemRandomNumberGenerator()
            return Difficulty.random(using: &g)
        }
    }
    var level: Difficulty = .easy {
        didSet {
            store()
        }
    }

    typealias Score = (player: Int, enemy: Int)
    var score: Score = (player: 0, enemy: 0) {
        didSet {
            store()
            scoreChanged?(score)
        }
    }

    var scoreChanged: ((_ score: Score) -> Void)?

    static func defaultPlayer() -> Player {
        let player = Player(level: .easy, score: (0, 0))
        return player
    }

    init(level: Difficulty, score: Score) {
        self.level = level
        self.score = score
    }

    enum Keys: String {
        case level = "Level"
        case scorePlayer = "Player"
        case scoreEnemy = "Enemy"
    }

    required convenience init?(coder: NSCoder) {
        let level = Difficulty(
            rawValue: coder.decodeInteger(forKey: Keys.level.rawValue) as Difficulty.RawValue
        ) ?? .easy
        let player = coder.decodeInteger(forKey: Keys.scorePlayer.rawValue)
        let enemy = coder.decodeInteger(forKey: Keys.scoreEnemy.rawValue)

        self.init(level: level, score: (player: player, enemy: enemy))
    }

    func encode(with coder: NSCoder) {
        coder.encode(level, forKey: Keys.level.rawValue)
        coder.encode(score.player, forKey: Keys.scorePlayer.rawValue)
        coder.encode(score.enemy, forKey: Keys.scoreEnemy.rawValue)
    }

    func store() {
        logger.trace("Player store to persistence level: \(level), score: \(score)")
        let defaults = UserDefaults.standard
        defaults.set(level.rawValue, forKey: Keys.level.rawValue)
        defaults.set(score.player, forKey: Keys.scorePlayer.rawValue)
        defaults.set(score.enemy, forKey: Keys.scoreEnemy.rawValue)
        defaults.synchronize()
    }

    func restore() {
        let defaults = UserDefaults.standard
        guard
            let levelValue = defaults.value(forKey: Keys.level.rawValue) as? Int,
            let level = Difficulty(rawValue: levelValue),
            let scorePlayer = defaults.value(forKey: Keys.scorePlayer.rawValue) as? Int,
            let scoreEnemy = defaults.value(forKey: Keys.scoreEnemy.rawValue) as? Int
        else {
            logger.error("Player restore failed")
            reset()
            return
        }
        let score = (player: scorePlayer, enemy: scoreEnemy)
        self.level = level
        self.score = score
        logger.trace("Player restored from persistence: level: \(level), score:\(score)")
    }

    func reset() {
        set(level: .easy)
        resetScore()
    }

    func set(level: Difficulty) {
        logger.trace("Player set level: \(level)")
        self.level = level
    }

    func resetScore() {
            logger.trace("Player reset score")
        self.score = (player: 0, enemy: 0)
    }

    func increasePlayersScore() {
        self.score = (player: self.score.player + 1, enemy:self.score.enemy)
    }

    func increaseEnemysScore() {
        self.score = (player: self.score.player, enemy:self.score.enemy + 1)
    }
}
