//
//  GameViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let view = view as? SKView,
            let scene = SKScene(fileNamed: "MenuScene")
        else { return }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill

        // Present the scene
        view.presentScene(scene)
        view.ignoresSiblingOrder = false
        view.showsFPS = false
        view.showsNodeCount = false
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
