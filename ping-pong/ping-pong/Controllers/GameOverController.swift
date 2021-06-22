//
//  GameOverController.swift
//  ping-pong
//
//  Created by Libor Kučera on 01.02.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

protocol GameOverGameScoreProvider: AnyObject {
    func saveScore(
        _ gamecontroller: GameOverController,
        completion: GameScoreCompletionBlock?
    )
}

class GameOverController: BaseViewController {
    weak var gameScoreDelegate: GameOverGameScoreProvider?

    @IBOutlet private weak var gameCenterButton: UIButton! {
        didSet {
            let title = NSLocalizedString("Game center", comment: "GAMEOVER_BUTTON_GAMECENTER")
            gameCenterButton.setTitle(title, for: .normal)
            gameCenterButton.titleLabel?.textColor = UIColor.GameOver.buttonText
            gameCenterButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            gameCenterButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var restartButton: UIButton! {
        didSet {
            let title = NSLocalizedString("Restart", comment: "GAMEOVER_BUTTON_RESTART")
            restartButton.setTitle(title, for: .normal)
            restartButton.titleLabel?.textColor = UIColor.GameOver.buttonText
            restartButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            restartButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var mainMenuButton: UIButton! {
        didSet {
            let title = NSLocalizedString("Main Menu", comment: "GAMEOVER_BUTTON_MAINMENU")
            mainMenuButton.setTitle(title, for: .normal)
            mainMenuButton.titleLabel?.textColor = UIColor.GameOver.buttonText
            mainMenuButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            mainMenuButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var saveScoreButton: UIButton! {
        didSet {
            let title = NSLocalizedString("Save Score", comment: "GAMEOVER_BUTTON_SAVESCORE")
            saveScoreButton.setTitle(title, for: .normal)
            saveScoreButton.titleLabel?.textColor = UIColor.GameOver.buttonText
            saveScoreButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            saveScoreButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.tintColor = .appBlack
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.GameOver.labelText
            titleLabel.font = .scaledHeadlineFont(for: .llPixel3)
            titleLabel.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var elapsedTimeLabel: UILabel! {
        didSet {
            elapsedTimeLabel.textColor = UIColor.GameOver.labelText
            elapsedTimeLabel.font = .scaledSystemFont(for: .llPixel3)
            elapsedTimeLabel.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            scoreLabel.textColor = UIColor.GameOver.labelText
            scoreLabel.font = .scaledSystemFont(for: .llPixel3)
            scoreLabel.adjustsFontForContentSizeCategory = true
        }
    }

    @IBAction private func mainMenuAction(_ sender: Any) {
        closeAction = .mainMenu
        closeBlock?(closeAction)
    }

    @IBAction private func restartAction(_ sender: Any) {
        closeAction = .restart
        closeBlock?(closeAction)
    }

    @IBAction private func saveScoreAction(_ sender: UIButton) {
        sender.isEnabled = false
        activityIndicator.startAnimating()
        gameScoreDelegate?.saveScore(self) { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.logger.error("Save error: \(error.localizedDescription)")
                sender.isEnabled = true
            } else {
                let message = NSLocalizedString("Score saved", comment: "GAMEOVER_BUTTON_SCORE_SAVED")
                sender.setTitle(message, for: .normal)
                self.closeAction = .mainMenu
                self.closeBlock?(self.closeAction)
            }
        }
    }

    var score: Player.Score = (player: 0, enemy: 0)
    var level: Player.Difficulty = .easy
    var time: ElapsedTime = ElapsedTime()

    enum CloseAction {
        case restart
        case mainMenu
    }

    private var closeAction: CloseAction = .mainMenu
    typealias CloseBlock = (CloseAction) -> Void
    var closeBlock: CloseBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContent()
    }
    
    private func setupView() {
        self.view.alpha = 0.9
        self.view.backgroundColor = UIColor.GameOver.background
        self.view.roundedCorners(
            corners: [.bottomLeft, .bottomRight],
            radius: 10.0
        )
        let layer = view.layer
        layer.borderWidth = 1
        layer.borderColor = UIColor.GameOver.border.cgColor
    }

    private func setupContent() {
        titleLabel.text = "\(NSLocalizedString("Game Over", comment: "GAMEOVER_TITLE_GAMEOVER"))"
        scoreLabel.text = (score.player > score.enemy)
            ? NSLocalizedString("You Won", comment: "GAMEOVER_LABEL_YOUWON")
            : NSLocalizedString("You Lost", comment: "GAMEOVER_LABEL_YOULOST")
            + " \(score.player) : \(score.enemy)"

        if let timeString = time.string() {
            elapsedTimeLabel.text = "\(NSLocalizedString("Time", comment: "GAMEOVER_LABEL_TIME")): \(timeString) sec"
        } else {
            elapsedTimeLabel.text = nil
        }

        saveScoreButton.isHidden = !(score.player > score.enemy)
        activityIndicator.stopAnimating()
    }
}
