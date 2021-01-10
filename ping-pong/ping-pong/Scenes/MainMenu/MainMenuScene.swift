//
//  MainMenuScene.swift
//  ping-pong
//
//  Created by Libor Kučera on 07/04/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import SpriteKit

class MainMenuScene: BaseScene {
    var playButton: ActionButton!
    var levelsButton: ActionButton!
    var scoreButton: ActionButton!

    override func didMove(to view: SKView) {
        playButton = (childNode(withName: "play") as! ActionButton)
        playButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            let randomLevel = Player.Difficulty.random()
            self.startGame(level: randomLevel)
        }

        levelsButton = (childNode(withName: "levels") as! ActionButton)
        levelsButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goLevelsMenu()
        }

        scoreButton = (childNode(withName: "score") as! ActionButton)
        levelsButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goScoreMenu()
        }
    }
}
