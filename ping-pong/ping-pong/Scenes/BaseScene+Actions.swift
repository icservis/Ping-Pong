//
//  BaseScene+Actions.swift
//  ping-pong
//
//  Created by Libor Kučera on 19/02/2020.
//  Copyright © 2020 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit
import Logging

class BaseScene: SKScene {
    lazy var logger: Logger = {
        var logger = Logger(label: "com.ic-servis.ping-pong.baseScene")
        logger.logLevel = .debug
        return logger
    }()

    lazy var player: Player = {
        let player = Player.defaultPlayer()
        player.scoreChanged = { [weak self] score in
            self?.scoreChanged(score)
        }
        player.levelChanged = { [weak self] level in
            self?.levelChanged(level)
        }
        return player
    }()

    func scoreChanged(_ score: Player.Score) { }

    func levelChanged(_ level: Player.Difficulty) { }
    
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
        logger.trace("Load scene: \(fileNamed)")
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
}
