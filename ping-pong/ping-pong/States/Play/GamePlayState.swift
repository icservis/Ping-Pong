//
//  GamePlayState.swift
//  ping-pong
//
//  Created by Libor Kučera on 08.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import GameplayKit

final class GamePlayState: BaseState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is GamePlayState.Type:
            return false
        case is MainMenuState.Type:
            return false
        case is LevelsMenuState.Type:
            return false
        case is PauseMenuState.Type:
            return true
        case is ScoreMenuState.Type:
            return false
        case is GameOverMenuState.Type:
            return true
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        scene.loadGame()
    }
}
