//
//  GameStateMachine.swift
//  ping-pong
//
//  Created by Libor Kučera on 08.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import GameplayKit
import Logging

class GameStateMachine: GKStateMachine {
    static func defaultMachine(scene: BaseScene) -> GameStateMachine {
        let machine = GameStateMachine(states: [
            GamePlayState(scene: scene),
            MainMenuState(scene: scene),
            LevelsMenuState(scene: scene),
            PauseMenuState(scene: scene),
            ScoreMenuState(scene: scene),
            GameOverMenuState(scene: scene)
        ])
        return machine
    }
}

extension BaseScene {
    func startGame(level: Player.Difficulty) {
        logger.trace("Start game with level: \(level)")
        //self.stateMachine.enter(GamePlayState.self)
        guard stateMachine.canEnterState(GamePlayState.self) else { return }
        if let scene = loadGame() {
            scene.player.set(level: level)
            scene.player.resetScore()
        }
    }

    func restartGame() {
        logger.trace("Restart game")
        //self.stateMachine.enter(GamePlayState.self)
        guard stateMachine.canEnterState(GamePlayState.self) else { return }
        if let scene = loadGame() {
            scene.player.resetScore()
        }
    }

    func resumeGame() {
        logger.trace("Resume game")
        //self.stateMachine.enter(GamePlayState.self)
        guard stateMachine.canEnterState(GamePlayState.self) else { return }
        if let scene = loadGame() {
            scene.player.restore()
        }
    }

    func pauseGame() {
        logger.trace("Pause game")
        //self.stateMachine.enter(PauseMenuState.self)
        guard stateMachine.canEnterState(PauseMenuState.self) else { return }
        loadPauseMenu()
    }

    func goMainMenu() {
        logger.trace("Go to Main menu")
        //self.stateMachine.enter(MainMenuState.self)
        guard stateMachine.canEnterState(MainMenuState.self) else { return }
        loadMainMenu()
    }

    func goLevelsMenu() {
        logger.trace("Go to levels menu")
        //self.stateMachine.enter(LevelsMenuState.self)
        guard stateMachine.canEnterState(LevelsMenuState.self) else { return }
        loadLevelsMenu()
    }

    func goScoreMenu() {
        logger.trace("Go to Score menu")
        //self.stateMachine.enter(ScoreMenuState.self)
        guard stateMachine.canEnterState(ScoreMenuState.self) else { return }
        loadScoreMenu()
    }

    func gameOverGame() {
        logger.trace("Go to Game over menu")
        //self.stateMachine.enter(GameOverMenuState.self)
        guard stateMachine.canEnterState(GameOverMenuState.self) else { return }
        loadGameOverMenu()
    }
}
