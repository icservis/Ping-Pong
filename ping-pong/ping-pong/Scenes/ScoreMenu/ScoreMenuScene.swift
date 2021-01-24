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
    var dashboardButton: ActionButton!
    var leaderboardButton: ActionButton!
    var achievementsButton: ActionButton!
    var challengesButton: ActionButton!

    override func didMove(to view: SKView) {
        menuButton = (childNode(withName: "menu") as! ActionButton)
        menuButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.goMainMenu()
        }

        dashboardButton = (childNode(withName: "dashboard") as! ActionButton)
        dashboardButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.instantiaGameCenter(state: .dashboard, completion: nil)
        }

        leaderboardButton = (childNode(withName: "leaderboard") as! ActionButton)
        leaderboardButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.instantiaGameCenter(state: .leaderboards, completion: nil)
        }

        achievementsButton = (childNode(withName: "achievements") as! ActionButton)
        achievementsButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.instantiaGameCenter(state: .achievements, completion: nil)
        }

        challengesButton = (childNode(withName: "challenges") as! ActionButton)
        challengesButton.onStateChange = { [weak self] state in
            guard let self = self, case .selected = state else { return }
            self.instantiaGameCenter(state: .challenges, completion: nil)
        }
    }
}
