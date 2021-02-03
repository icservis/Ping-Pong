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

    // MARK: Level
    enum Difficulty: Int, CaseIterable, CustomStringConvertible {
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

        var description: String {
            switch self {
            case .easy:
                return NSLocalizedString("EASY", comment: "GAME_LEVEL_EASY")
            case .medium:
                return NSLocalizedString("MEDIUM", comment: "GAME_LEVEL_MEDIUM")
            case .hard:
                return NSLocalizedString("HARD", comment: "GAME_LEVEL_HARD")
            }
        }
    }

    var level: Difficulty = .easy {
        didSet {
            levelChanged?(level)
        }
    }

    var levelChanged: ((_ level: Difficulty) -> Void)?

    func set(level: Difficulty) {
        logger.trace("Player set level: \(level)")
        self.level = level
    }

    // MARK: Score
    typealias ScoreType = Int
    static let finalScore: ScoreType = 10
    typealias Score = (player: ScoreType, enemy: ScoreType)

    var score: Score = (player: 0, enemy: 0) {
        didSet {
            scoreChanged?(score)
        }
    }

    var scoreChanged: ((_ score: Score) -> Void)?

    func resetScore() {
        logger.trace("Player reset score")
        self.score = (player: 0, enemy: 0)
    }

    func increasePlayersScore() -> Bool {
        self.score = (player: self.score.player + 1, enemy:self.score.enemy)
        return self.score.player < Self.finalScore
    }

    func increaseEnemysScore() -> Bool {
        self.score = (player: self.score.player, enemy:self.score.enemy + 1)
        return self.score.enemy < Self.finalScore
    }

    // MARK: Default Player
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
}
