//
//  TopPlayersViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit
import CountdownTimer

final class GameController: BaseViewController {
    var level: Player.Difficulty = .easy
    weak var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let gameScene = loadScene("GameScene") as? GameScene else {
            return
        }
        gameScene.controller = self
        self.gameScene = gameScene


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        gameScene?.resetGame(level: level)
    }

    func pauseGame(completion: PauseMenuController.CloseBlock?) {
        coordinator?.loadPauseMenu(completion: completion)
    }

    func gameOver(
        result: GameResult,
        completion: GameOverController.CloseBlock?
    ) {
        coordinator?.loadGameOver(
            result: result,
            completion: completion
        )
    }

    func loadCountDownTimer(
        initialCount: Int,
        tick: CountDownController.TickBlock?,
        completion: CountDownController.CompletionBlock?
    ) {
        coordinator?.loadCountDownTimer(
            initialCount: initialCount,
            tick: tick,
            completion: completion
        )
    }
}
