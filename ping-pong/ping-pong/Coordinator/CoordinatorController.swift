//
//  GameViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit
import Logging

protocol Coordinator: AnyObject {
    typealias CompletionBlock = () -> Void
    var currentController: UIViewController? { get }
    func configureAccessPoint(isActive: Bool, showHighlights: Bool)

    func loadMainMenu()
    func loadGame(level: Player.Difficulty)
    func loadPauseMenu(completion: CompletionBlock?)
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
        guard let controller = instatiateController(identifier: "Intro") as? IntroController else {
            fatalError("Can not instantiate controller")
        }
        controller.coordinator = self
        return controller
    }()

    lazy var mainMenuController: MainMenuController = {
        guard let controller = instatiateController(identifier: "MainMenu") as? MainMenuController else {
            fatalError("Can not instantiate controller")
        }
        controller.coordinator = self
        return controller
    }()

    lazy var pauseMenuController: BottomSheetController = {
        guard let controller = instatiateController(identifier: "BottomSheet") as? BottomSheetController else {
            fatalError("Can not instantiate controller")
        }
        return controller
    }()

    lazy var gameController: GameController = {
        guard let controller = instatiateController(identifier: "Game") as? GameController else {
            fatalError("Can not instantiate controller")
        }
        controller.coordinator = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        loadIntro()
    }

    @IBAction func showGameCenterDashboard(_ sender: Any?, completion: (() -> Void)?) {
        let vc = GKGameCenterViewController(state: .dashboard)
        vc.gameCenterDelegate = self
        present(
            vc,
            animated: true,
            completion: completion
        )
    }

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

    func loadViewController(_ viewController: UIViewController) {
        logger.trace("Load \(viewController)")
        addChild(viewController)
        viewController.didMove(toParent: self)
        currentController = viewController

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func transition(to newController: UIViewController) {
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
        }
    }

    func instatiateController(identifier: String) -> UIViewController? {
        logger.trace("Instantiate controller with identifier \(identifier)")
        guard let storyboard = storyboard else { return nil }
        return storyboard.instantiateViewController(identifier: identifier)
    }
}

extension CoordinatorController: Coordinator {
    func loadMainMenu() {
        logger.debug("Load Main Menu")
        transition(to: mainMenuController)
    }

    func loadPauseMenu(completion: CompletionBlock?) {
        logger.debug("Pause game")
        pauseMenuController.closeBlock = { [weak self] forced in
            self?.dismiss(animated: true) {
                //guard forced else { return }
                completion?()
            }
        }
        pauseMenuController.modalPresentationStyle = .automatic
        pauseMenuController.modalTransitionStyle = .coverVertical
        present(pauseMenuController, animated: true, completion: nil)
    }

    func loadGame(level: Player.Difficulty) {
        logger.debug("Load game level: \(level)")
        gameController.level = level
        transition(to: gameController)
    }

    func configureAccessPoint(isActive: Bool, showHighlights: Bool) {
        logger.debug("Configure Access Point isActive: \(isActive)")
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.showHighlights = showHighlights
        GKAccessPoint.shared.isActive = isActive
    }
}

extension CoordinatorController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
        logger.trace("GameCenter Controlled did finish presentation")
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
