//
//  TopPlayersViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit

class GameController: BaseViewController {
    var level: Player.Difficulty = .easy
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let gameScene = loadScene("GameScene") as? GameScene else {
            return
        }
        gameScene.controller = self
        gameScene.player.set(level: level)
        gameScene.player.resetScore()
    }

    func pauseGame(completion: Coordinator.CompletionBlock?) {
        coordinator?.loadPauseMenu(completion: completion)
    }
}
