//
//  Coordinator.swift
//  ping-pong
//
//  Created by Libor Kučera on 02.07.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import CountdownTimer

typealias GameCenterCloseBlock = () -> Void
typealias GameScoreCompletionBlock = (Error?) -> Void

protocol Coordinator: AnyObject {
    var currentController: UIViewController? { get }

    func loadMainMenu()
    func loadGame(level: Player.Difficulty)
    func loadPauseMenu(completion: PauseMenuController.CloseBlock?)
    func loadGameOver(
        result: GameResult,
        completion: GameOverController.CloseBlock?
    )
    func loadCountDownTimer(
        initialCount: Int,
        tick: CountDownController.TickBlock?,
        completion: CountDownController.CompletionBlock?
    )

    func isPlayerAuthenticated() -> Bool
    func loadGameCenterDashboard(completion: GameCenterCloseBlock?)
    func saveScoreToGameCenter(
        result: GameResult,
        completion: GameScoreCompletionBlock?
    )
}
