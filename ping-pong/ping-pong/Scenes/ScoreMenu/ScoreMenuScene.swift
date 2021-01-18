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
    var topPlayersButton: ActionButton!
    var achievementsButton: ActionButton!

    override func didMove(to view: SKView) {
        menuButton = (childNode(withName: "menu") as! ActionButton)
        menuButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goMainMenu()
        }

        topPlayersButton = (childNode(withName: "topPlayers") as! ActionButton)
        topPlayersButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.instantiateViewController(with: "TopPlayers", completion: nil)
        }

        achievementsButton = (childNode(withName: "achievements") as! ActionButton)
        achievementsButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.instantiateViewController(with: "Achievements", completion: nil)
        }
    }
}
