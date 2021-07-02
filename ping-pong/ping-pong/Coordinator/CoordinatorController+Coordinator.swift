//
//  CoordinatorController+Coordinator.swift
//  ping-pong
//
//  Created by Libor Kučera on 02.07.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit
import CountdownTimer

extension CoordinatorController: Coordinator {
    func loadGame(level: Player.Difficulty) {
        logger.debug("Load game level: \(level)")
        gameController.level = level
        transition(to: gameController)
    }

    func loadMainMenu() {
        logger.debug("Load Main Menu")
        transition(to: mainMenuController)
    }

    func loadPauseMenu(completion: PauseMenuController.CloseBlock?) {
        logger.debug("Load Pause game")
        guard let pauseMenuController = instatiateController(identifier: .pauseMenu) as? PauseMenuController else { return }
        presenter.direction = .bottom
        presenter.relativeSize = .init(
            proportion: .custom(1),
            length: .custom(0.40)
        )
        pauseMenuController.transitioningDelegate = presenter
        pauseMenuController.modalPresentationStyle = .custom
        pauseMenuController.closeBlock = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .mainMenu:
                self.loadMainMenu()
            case .restart:
                break
            case .resume:
                break
            }
            self.dismiss(animated: true) {
                completion?(result)
            }
        }
        present(pauseMenuController, animated: true, completion: nil)
    }

    func loadGameOver(
        result: GameResult,
        completion: GameOverController.CloseBlock?
    ) {
        logger.debug("Load Game over")
        guard let gameOverController = instatiateController(identifier: .gameOver) as? GameOverController else { return }
        presenter.direction = .top
        presenter.relativeSize = .init(
            proportion: .custom(1),
            length: .custom(1)
        )
        gameOverController.transitioningDelegate = presenter
        gameOverController.modalPresentationStyle = .custom
        gameOverController.result = result
        gameOverController.gameScoreDelegate = self
        gameOverController.closeBlock = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .mainMenu:
                self.loadMainMenu()
            case .restart:
                break
            }
            self.dismiss(animated: true) {
                completion?(result)
            }
        }
        present(
            gameOverController,
            animated: true,
            completion: nil
        )
    }

    func loadCountDownTimer(
        initialCount: Int,
        tick: CountDownController.TickBlock?,
        completion: CountDownController.CompletionBlock?
    ) {
        logger.debug("Load CountDownTimer Controller")
        let countDownController = CountDownController()
        countDownController.initialCount = initialCount
        countDownController.tick = tick
        countDownController.completion = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: false) {
                completion?()
            }
        }
        countDownController.modalPresentationStyle = .overFullScreen
        present(
            countDownController,
            animated: false,
            completion: nil
        )
    }

    func isPlayerAuthenticated() -> Bool {
        return GKLocalPlayer.local.isAuthenticated
    }

    func loadGameCenterDashboard(completion: GameCenterCloseBlock?) {
        logger.debug("Load GameCenter Dashboard")
        self.gameCenterCloseBlock = completion
        let gameCenterController = GKGameCenterViewController(state: .dashboard)
        gameCenterController.gameCenterDelegate = self
        present(
            gameCenterController,
            animated: true,
            completion: nil
        )
    }

    func saveScoreToGameCenter(
        result: GameResult,
        completion: GameScoreCompletionBlock?
    ) {
        logger.debug("Saving Score to LeaderBoard")
        let player = GKLocalPlayer.local
        guard player.isAuthenticated else {
            let error = NSError(
                domain: Bundle.main.bundleIdentifier ?? "",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Player not authenticated", comment: "ERRO_GAMECENTER_NOTLOGGED")
                ]
            )
            logger.error("Save score error: \(error.localizedDescription)")
            completion?(error)
            return
        }

        let levelScore = GKLeaderboardScore()
        levelScore.player = player
        levelScore.value = result.time.score()
        levelScore.leaderboardID = LeaderBoard.topByLevel(result.level).identifier

        let allStarsScore = GKLeaderboardScore()
        allStarsScore.player = player
        allStarsScore.value = result.time.score()
        allStarsScore.leaderboardID = LeaderBoard.weeklyAllStars.identifier
        allStarsScore.context = result.level.context

        let scores: [GKLeaderboardScore] = [levelScore, allStarsScore]

        let challenges: [GKChallenge] = []

        GKScore.report(
            scores,
            withEligibleChallenges: challenges,
            withCompletionHandler: { [weak self] error in
                if let error = error {
                    self?.logger.error("Save score error: \(error.localizedDescription)")
                } else {
                    self?.logger.debug("Score saved successfully")
                }
                completion?(error)
            }
        )
    }
}
