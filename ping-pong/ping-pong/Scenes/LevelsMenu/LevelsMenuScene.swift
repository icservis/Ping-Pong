//
//  MapScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 19/02/2020.
//  Copyright © 2020 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit

class LevelsMenuScene: BaseScene {
    var footballButton: ActionButton!
    var tenisButton: ActionButton!
    var hockeyButton: ActionButton!
    var menuButton: ActionButton!

    override func didMove(to view: SKView) {
        footballButton = (childNode(withName: "football") as! ActionButton)
        footballButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.startGame(level: .easy)
        }

        tenisButton = (childNode(withName: "tenis") as! ActionButton)
        tenisButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.startGame(level: .medium)
        }

        hockeyButton = (childNode(withName: "hockey") as! ActionButton)
        hockeyButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.startGame(level: .hard)
        }

        menuButton = (childNode(withName: "menu") as! ActionButton)
        menuButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goMainMenu()
        }
    }
}
