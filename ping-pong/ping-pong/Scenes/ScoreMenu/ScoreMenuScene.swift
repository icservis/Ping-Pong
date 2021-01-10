//
//  ScoreMenuScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 09.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit

class ScoreMenuScene: BaseScene {
    var menuButton: ActionButton!

    override func didMove(to view: SKView) {
        menuButton = (childNode(withName: "menu") as! ActionButton)
        menuButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goMainMenu()
        }
    }
}
