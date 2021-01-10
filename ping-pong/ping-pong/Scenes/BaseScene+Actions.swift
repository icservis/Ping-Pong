//
//  BaseScene+Actions.swift
//  ping-pong
//
//  Created by Libor Kučera on 19/02/2020.
//  Copyright © 2020 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit
import Logging

class BaseScene: SKScene {
    lazy var logger: Logger = {
        var logger = Logger(label: "com.ic-servis.ping-pong.baseScene")
        logger.logLevel = .trace
        return logger
    }()

    lazy var player: Player = {
        let player = Player.defaultPlayer()
        player.scoreChanged = { [weak self] score in
            self?.scoreChanged(score)
        }
        return player
    }()

    func scoreChanged(_ score: Player.Score) { }
    
    lazy var stateMachine: GameStateMachine = {
        return GameStateMachine.defaultMachine(scene: self)
    }()
    //
    // MARK: Scenes
    //

    @discardableResult
    private func loadScene(
        _ fileNamed: String,
        transition: SKTransition = .fade(withDuration: 0.25)
    ) -> SKScene? {
        guard
            let view = view,
            let scene = SKScene(fileNamed: fileNamed)
        else { return nil }
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit

        // Present the scene
        view.presentScene(scene, transition: transition)
        view.ignoresSiblingOrder = false
        view.showsFPS = false
        view.showsNodeCount = false

        return scene
    }

    @discardableResult
    func loadGame() -> GameScene? {
        return loadScene("GameScene") as? GameScene
    }

    @discardableResult
    func loadMainMenu() -> MainMenuScene? {
        return loadScene("MainMenuScene") as? MainMenuScene
    }

    @discardableResult
    func loadLevelsMenu() -> LevelsMenuScene? {
        return loadScene("LevelsMenuScene") as? LevelsMenuScene
    }

    @discardableResult
    func loadPauseMenu() -> PauseMenuScene? {
        return loadScene("PauseMenuScene") as? PauseMenuScene
    }

    @discardableResult
    func loadScoreMenu() -> ScoreMenuScene? {
        return loadScene("ScoreMenuScene") as? ScoreMenuScene
    }

    @discardableResult
    func loadGameOverMenu() -> GameOverScene? {
        return loadScene("GameOverScene") as? GameOverScene
    }
}
