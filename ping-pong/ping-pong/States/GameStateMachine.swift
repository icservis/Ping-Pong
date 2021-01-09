//
//  GameStateMachine.swift
//  ping-pong
//
//  Created by Libor Kučera on 08.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import GameplayKit

class GameStateMachine: GKStateMachine { }

extension BaseScene {
    func restartGame() {
        resetScore()
        self.stateMachine.enter(GamePlayState.self)
    }

    func pauseGame() {
        self.stateMachine.enter(PauseMenuState.self)
    }

    func resumeGame() {
        self.stateMachine.enter(GamePlayState.self)
    }

    func gameOverGame() {
        self.stateMachine.enter(GameOverMenuState.self)
    }

    func goMainMenu() {
        self.stateMachine.enter(MainMenuState.self)
    }

    func goLevelsMenu() {
        self.stateMachine.enter(LevelsMenuState.self)
    }

    func goScoreMenu() {
        self.stateMachine.enter(ScoreMenuState.self)
    }
}
