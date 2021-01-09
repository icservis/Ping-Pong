//
//  BaseScene+Actions.swift
//  ping-pong
//
//  Created by Libor Kučera on 19/02/2020.
//  Copyright © 2020 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit

class BaseScene: SKScene {
    lazy var stateMachine: GameStateMachine = {
        let machine = GameStateMachine(states: [
            GamePlayState(scene: self),
            MainMenuState(scene: self),
            LevelsMenuState(scene: self),
            PauseMenuState(scene: self),
            ScoreMenuState(scene: self),
            GameOverMenuState(scene: self)
        ])
        return machine
    }()

    enum Difficulty {
        case easy
        case medium
        case hard
    }
    var difficulty: Difficulty = .easy

    //
    // MARK: Score
    typealias Score = (player: Int, enemy: Int)
    var score: Score = (0, 0) {
        didSet {
            updateScore()
        }
    }

    func updateScore() {
        let defaults = UserDefaults.standard
        defaults.set(score.player, forKey: "player")
        defaults.set(score.enemy, forKey: "enemy")
        defaults.synchronize()
    }

    func restoreScore() {
        let defaults = UserDefaults.standard
        guard
            let playerScore = defaults.value(forKey: "player") as? Int,
            let enemyScore = defaults.value(forKey: "enemy") as? Int
        else {
            resetScore()
            return
        }
        score = (player: playerScore, enemy: enemyScore)
    }

    func resetScore() {
        score = (player: 0, enemy: 0)
    }

    //
    // MARK: Scenes
    //

    private func loadScene(_ fileNamed: String) {
        guard
            let view = view,
            let scene = SKScene(fileNamed: fileNamed)
        else { return }
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit

        // Present the scene
        view.presentScene(scene)
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = false
    }

    func loadGame() {
        loadScene("GameScene")
    }

    func loadMainMenu() {
        loadScene("MainMenuScene")
    }

    func loadLevelsMenu() {
        loadScene("LevelsMenuScene")
    }

    func loadPauseMenu() {
        loadScene("PauseMenuScene")
    }

    func loadScoreMenu() {
        loadScene("ScoreMenuScene")
    }

    func loadGameOverMenu() {
        loadScene("GameOverScene")
    }
}
