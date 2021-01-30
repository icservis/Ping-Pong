//
//  AchievementsViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit

class MainMenuController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var gameButton: UIButton!

    @IBAction func loadGame(_ sender: UIButton) {
        let level = Player.Difficulty.random()
        logger.trace("Load Game level: \(level)")
        coordinator?.loadGame(level: level)
    }
}
