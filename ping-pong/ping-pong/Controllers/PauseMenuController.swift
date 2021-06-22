//
//  PauseMenuController.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

final class PauseMenuController: BaseViewController {

    @IBOutlet private weak var restartButton: UIButton! {
        didSet {
            let title = NSLocalizedString("Restart", comment: "PAUSEMENU_BUTTON_RESTART")
            restartButton.setTitle(title, for: .normal)
            restartButton.titleLabel?.textColor = UIColor.PauseMenu.buttonText
            restartButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            restartButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var mainMenuButton: UIButton! {
        didSet {
            let title = NSLocalizedString("Main Menu", comment: "PAUSEMENU_BUTTON_MAINMENU")
            mainMenuButton.setTitle(title, for: .normal)
            mainMenuButton.titleLabel?.textColor = UIColor.PauseMenu.buttonText
            mainMenuButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            mainMenuButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.PauseMenu.labelText
            titleLabel.font = .scaledHeadlineFont(for: .llPixel3)
            titleLabel.adjustsFontForContentSizeCategory = true
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

    enum CloseAction {
        case resume
        case restart
        case mainMenu
    }
    
    private var closeAction: CloseAction = .resume
    typealias CloseBlock = (CloseAction) -> Void
    var closeBlock: CloseBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard closeAction == .resume else { return }
        closeBlock?(closeAction)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    private func setupView() {
        self.view.alpha = 0.9
        self.view.backgroundColor = UIColor.PauseMenu.background
        self.view.roundedCorners(
            corners: [.topLeft, .topRight],
            radius: 25.0
        )
        let layer = view.layer
        layer.borderWidth = 1
        layer.borderColor = UIColor.PauseMenu.border.cgColor
    }
}
