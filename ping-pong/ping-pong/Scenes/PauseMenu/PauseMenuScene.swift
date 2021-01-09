//
//  ResumeScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 17/02/2020.
//  Copyright © 2020 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit

class PauseMenuScene: BaseScene {
    var resumeButton: ActionButton!
    var restartButton: ActionButton!
    var menuButton: ActionButton!

    override func didMove(to view: SKView) {
        resumeButton = (childNode(withName: "resume") as! ActionButton)
        resumeButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.resumeGame()
        }

        restartButton = (childNode(withName: "restart") as! ActionButton)
        restartButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.restartGame()
        }

        menuButton = (childNode(withName: "menu") as! ActionButton)
        menuButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goMainMenu()
        }
    }
}
