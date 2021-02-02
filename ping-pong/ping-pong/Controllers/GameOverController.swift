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

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.GameOver.labelText
            titleLabel.font = .scaledHeadlineFont(for: .llPixel3)
            titleLabel.adjustsFontForContentSizeCategory = true
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

    deinit {
        closeBlock?(closeAction)
    }
}
