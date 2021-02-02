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

extension BaseScene { }
