//
//  BaseViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 08.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit
import Logging

class BaseViewController: UIViewController {
    lazy var logger: Logger = {
        var logger = Logger(label: "com.ic-servis.ping-pong.baseViewController")
        logger.logLevel = .trace
        return logger
    }()
    
    @discardableResult
    func loadScene(
        _ fileNamed: String,
        transition: SKTransition = .fade(withDuration: 0.25)
    ) -> SKScene? {
        logger.trace("Load scene: \(fileNamed)")
        guard
            let view = view as? SKView,
            let scene = SKScene(fileNamed: fileNamed)
        else { return nil }
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit

        // Present the scene
        view.presentScene(scene, transition: transition)
        view.ignoresSiblingOrder = false
        view.showsFPS = false
        view.showsNodeCount = false

        return scene
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
