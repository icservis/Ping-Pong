//
//  MenuScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 07/04/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: BaseScene {
    var playButton: ActionButton!
    var mapButton: ActionButton!

    override func didMove(to view: SKView) {
        playButton = (childNode(withName: "play") as! ActionButton)
        playButton.onStateChange = { [weak self] state in
            guard case .selected = state else { return }
            self?.restartGame()
        }

        mapButton = (childNode(withName: "map") as! ActionButton)
        mapButton.onStateChange = { [weak self] state in
            guard case .selected = state else { return }
            self?.loadMapMenu()
        }
    }
}
