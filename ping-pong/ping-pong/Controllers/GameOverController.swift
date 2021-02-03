//
//  GameOverController.swift
//  ping-pong
//
//  Created by Libor Kučera on 01.02.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

class GameOverController: UIViewController {
    @IBOutlet private weak var closeButton: UIButton! {
        didSet {
            closeButton.titleLabel?.textColor = UIColor.GameOver.buttonText
            closeButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            closeButton.titleLabel?.adjustsFontForContentSizeCategory = true
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
            elapsedTimeLabel.font = .scaledHeadlineFont(for: .llPixel3)
            elapsedTimeLabel.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            scoreLabel.textColor = UIColor.GameOver.labelText
            scoreLabel.font = .scaledHeadlineFont(for: .llPixel3)
            scoreLabel.adjustsFontForContentSizeCategory = true
        }
    }

    @IBAction private func mainMenuAction(_ sender: Any) {
        closeAction = .mainMenu
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction private func restartAction(_ sender: Any) {
        closeAction = .restart
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    lazy var elapsedTimeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.allowsFloats = true

        return formatter
    }()

    var score: Player.Score = (player: 0, enemy: 0)
    var time: TimeInterval = 0

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
            corners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
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

        if let timeString = elapsedTimeFormatter.string(from: time) {
            elapsedTimeLabel.text = "\(NSLocalizedString("Time", comment: "GAMEOVER_LABEL_TIME")): \(timeString) sec"
        } else {
            elapsedTimeLabel.text = nil
        }
    }

    deinit {
        closeBlock?(closeAction)
    }
}
