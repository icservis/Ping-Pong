//
//  MainMenuState.swift
//  ping-pong
//
//  Created by Libor Kučera on 09.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import GameplayKit

final class MainMenuState: BaseState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is GamePlayState.Type:
            return true
        case is MainMenuState.Type:
            return false
        case is LevelsMenuState.Type:
            return true
        case is PauseMenuState.Type:
            return false
        case is ScoreMenuState.Type:
            return true
        case is GameOverMenuState.Type:
            return false
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        
    }
}
