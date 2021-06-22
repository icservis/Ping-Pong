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
        level: Player.Difficulty,
        score: Player.Score,
        time: ElapsedTime,
        completion: GameOverController.CloseBlock?
    ) {
        coordinator?.loadGameOver(
            level: level,
            score: score,
            time: time,
            completion: completion
        )
    }

    func loadCountDownTimer(
        initialCount: Int,
        completion: CountDownController.CompletionBlock?
    ) {
        coordinator?.loadCountDownTimer(
            initialCount: initialCount,
            completion: completion
        )
    }
}
