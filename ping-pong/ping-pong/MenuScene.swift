//
//  MenuScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 07/04/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    var playButton: ActionButton!

    override func didMove(to view: SKView) {
        playButton = (childNode(withName: "play") as! ActionButton)
        playButton.onStateChange = { [weak self] state in
            guard case .selected = state else { return }
            self?.loadGame()
        }
    }

    private func loadGame() {
        if let view = view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = false
        }
    }
}
