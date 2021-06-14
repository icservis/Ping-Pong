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

protocol Coordinator: AnyObject {
    var currentController: UIViewController? { get }

    func loadGameCenterDashboard(completion: GameCenterCloseBlock?)
    func configureAccessPoint(
        isActive: Bool,
        showHighlights: Bool,
        location: GKAccessPoint.Location
    )

    func loadMainMenu()
    func loadGame(level: Player.Difficulty)
    func loadPauseMenu(completion: PauseMenuController.CloseBlock?)
    func loadGameOver(
        score: Player.Score,
        time: TimeInterval,
        completion: GameOverController.CloseBlock?
    )
    func loadCountDownTimer(
        initialCount: Int,
        completion: CountDownController.CompletionBlock?
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
        logger.logLevel = .trace
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
            self?.currentController?.removeFromParent()
            self?.currentController = newController
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
        logger.debug("Pause game")
        guard let pauseMenuController = instatiateController(identifier: .pauseMenu) as? PauseMenuController else { return }
        presenter.direction = .bottom
        pauseMenuController.transitioningDelegate = presenter
        pauseMenuController.modalPresentationStyle = .custom
        pauseMenuController.closeBlock = { [weak self] result in
            switch result {
            case .mainMenu:
                self?.loadMainMenu()
            case .restart:
                break
            case .resume:
                break
            }
            completion?(result)
        }
        present(pauseMenuController, animated: true, completion: nil)
    }

    func loadGameOver(
        score: Player.Score,
        time: TimeInterval,
        completion: GameOverController.CloseBlock?
    ) {
        logger.debug("Game over")
        guard let gameOverController = instatiateController(identifier: .gameOver) as? GameOverController else { return }
        presenter.direction = .top
        presenter.relativeSize = .init(proportion: .custom(1), length: .custom(0.60))
        gameOverController.transitioningDelegate = presenter
        gameOverController.modalPresentationStyle = .custom
        gameOverController.score = score
        gameOverController.time = time
        gameOverController.closeBlock = { [weak self] result in
            switch result {
            case .mainMenu:
                self?.loadMainMenu()
            case .restart:
                break
            }
            completion?(result)
        }
        present(gameOverController, animated: true, completion: nil)
    }

    func configureAccessPoint(
        isActive: Bool,
        showHighlights: Bool,
        location: GKAccessPoint.Location
    ) {
        logger.debug("Configure Access Point isActive: \(isActive)")
        GKAccessPoint.shared.location = location
        GKAccessPoint.shared.showHighlights = showHighlights
        GKAccessPoint.shared.isActive = isActive
    }

    func loadGameCenterDashboard(completion: GameCenterCloseBlock?) {
        self.gameCenterCloseBlock = completion
        let gameCenterController = GKGameCenterViewController(state: .dashboard)
        gameCenterController.gameCenterDelegate = self
        present(
            gameCenterController,
            animated: true,
            completion: nil
        )
    }

    func loadCountDownTimer(initialCount: Int, completion: CountDownController.CompletionBlock?) {
        logger.debug("Load CountDownTimer Controller")
        let countDownController = CountDownController()
        countDownController.initialCount = initialCount
        countDownController.tick = { [weak self] count in
            self?.logger.trace("CountDown Tick: \(count)")
        }
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
