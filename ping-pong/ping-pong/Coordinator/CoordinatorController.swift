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


    var gameCenterCloseBlock: GameCenterCloseBlock?

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

extension CoordinatorController {
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
