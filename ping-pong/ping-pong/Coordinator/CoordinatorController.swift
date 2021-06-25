//
//  GameViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit
import ModalPresentation
import CountdownTimer
import Logging

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

enum StoryboardIdentifier: String {
    case intro = "Intro"
    case game = "Game"
    case mainMenu = "MainMenu"
    case pauseMenu = "PauseMenu"
    case gameOver = "GameOver"
}

final class CoordinatorController: UIViewController {
    lazy var logger: Logger = {
        var logger = Logger(label: "com.ic-servis.ping-pong.coordinatorController")
        logger.logLevel = .debug
        return logger
    }()

    weak var currentController: UIViewController? {
        didSet {
            logger.trace("Current controller: \(String(describing: currentController))")
        }
    }

    lazy var introController: IntroController = {
        guard let controller = instatiateController(identifier: .intro) as? IntroController else {
            fatalError("Can not instantiate controller")
        }
        controller.coordinator = self
        return controller
    }()

    lazy var mainMenuController: MainMenuController = {
        guard let controller = instatiateController(identifier: .mainMenu) as? MainMenuController else {
            fatalError("Can not instantiate controller")
        }
        controller.coordinator = self
        return controller
    }()

    lazy var gameController: GameController = {
        guard let controller = instatiateController(identifier: .game) as? GameController else {
            fatalError("Can not instantiate controller")
        }
        controller.coordinator = self
        return controller
    }()

    lazy var presenter = SlideInPresentationCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        loadIntro()
    }


    private var gameCenterCloseBlock: GameCenterCloseBlock?

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

private extension CoordinatorController {
    func loadIntro() {
        logger.trace("Load Intro")
        transition(to: introController)
    }

    func loadViewController(_ viewController: UIViewController) {
        logger.trace("Load \(viewController)")
        addChild(viewController)
        viewController.didMove(toParent: self)
        currentController = viewController

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func transition(to newController: UIViewController, completion: (() -> Void)? = nil) {
        guard let currentController = currentController else {
            loadViewController(newController)
            return
        }
        logger.trace("Transtion from \(String(describing: currentController)) to \(String(describing: newController))")
        currentController.willMove(toParent: nil)
        self.addChild(newController)

        self.transition(
            from: currentController,
            to: newController,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { }
        ) { [weak self] finished in
            guard let self = self else { return }
            currentController.removeFromParent()
            self.currentController = newController
            newController.didMove(toParent: self)
            completion?()
        }
    }

    func instatiateController(identifier: StoryboardIdentifier) -> UIViewController? {
        logger.trace("Instantiate controller with identifier \(identifier.rawValue)")
        guard let storyboard = storyboard else { return nil }
        return storyboard.instantiateViewController(identifier: identifier.rawValue)
    }

    func authenticateUser() {
        logger.trace("Authenticate user")
        let player = GKLocalPlayer.local
        player.authenticateHandler = { [weak self] vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Authentification error")
                return
            }
            guard let self = self, let vc = vc else { return }
            self.present(vc, animated: true, completion: nil)
        }
    }
}

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

extension CoordinatorController: GameOverGameScoreProvider {
    func saveScore(
        _ result: GameResult,
        completion: GameScoreCompletionBlock?
    ) {
        saveScoreToGameCenter(
            result: result,
            completion: completion
        )
    }
}

extension CoordinatorController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
        logger.trace("GameCenter Controlled did finish presentation")
        gameCenterViewController.dismiss(animated: true) { [weak self] in
            self?.gameCenterCloseBlock?()
        }
    }
}
