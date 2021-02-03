//
//  AchievementsViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit

final class MainMenuController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var gameButton: UIButton! {
        didSet {
            gameButton.titleLabel?.textColor = UIColor.MainMenu.buttonText
            gameButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            gameButton.titleLabel?.adjustsFontForContentSizeCategory = true
            gameButton.setTitle(
                NSLocalizedString("Random level", comment: "MAINMENU_BUTTON_LEVELRANDOM"),
                for: .normal
            )
        }
    }
    @IBAction func loadGame(_ sender: UIButton) {
        let level = Player.Difficulty.random()
        logger.trace("Load Game level: \(level)")
        coordinator?.loadGame(level: level)
    }

    @IBOutlet weak var gameLevelEasy: UIButton! {
        didSet {
            gameLevelEasy.titleLabel?.textColor = UIColor.MainMenu.buttonText
            gameLevelEasy.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            gameLevelEasy.titleLabel?.adjustsFontForContentSizeCategory = true
            gameLevelEasy.setTitle(
                NSLocalizedString("Easy level", comment: "MAINMENU_BUTTON_LEVELEASY"),
                for: .normal
            )
        }
    }
    @IBAction func loadGameLevelEasy(_ sender: UIButton) {
        let level = Player.Difficulty.easy
        logger.trace("Load Game level: \(level)")
        coordinator?.loadGame(level: level)
    }

    @IBOutlet weak var gameLevelMedium: UIButton! {
        didSet {
            gameLevelMedium.titleLabel?.textColor = UIColor.MainMenu.buttonText
            gameLevelMedium.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            gameLevelMedium.titleLabel?.adjustsFontForContentSizeCategory = true
            gameLevelMedium.setTitle(
                NSLocalizedString("Medium level", comment: "MAINMENU_BUTTON_LEVELMEDIUM"),
                for: .normal
            )
        }
    }
    @IBAction func loadGameLevelMedium(_ sender: UIButton) {
        let level = Player.Difficulty.medium
        logger.trace("Load Game level: \(level)")
        coordinator?.loadGame(level: level)
    }

    @IBOutlet weak var gameLevelHard: UIButton! {
        didSet {
            gameLevelHard.titleLabel?.textColor = UIColor.MainMenu.buttonText
            gameLevelHard.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            gameLevelHard.titleLabel?.adjustsFontForContentSizeCategory = true
            gameLevelHard.setTitle(
                NSLocalizedString("Hard level", comment: "MAINMENU_BUTTON_LEVELHARD"),
                for: .normal
            )
        }
    }
    @IBAction func loadGameLevelHard(_ sender: UIButton) {
        let level = Player.Difficulty.hard
        logger.trace("Load Game level: \(level)")
        coordinator?.loadGame(level: level)
    }
}
