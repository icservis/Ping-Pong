//
//  PauseMenuController.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

class PauseMenuController: UIViewController {
    @IBOutlet private weak var closeButton: UIButton! {
        didSet {
            closeButton.titleLabel?.textColor = UIColor.PauseMenu.buttonText
            closeButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            closeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.PauseMenu.labelText
            titleLabel.font = .scaledHeadlineFont(for: .llPixel3)
            titleLabel.adjustsFontForContentSizeCategory = true
        }
    }

    @IBAction private func closeAction(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    typealias CloseBlock = () -> Void
    var closeBlock: CloseBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

    deinit {
        closeBlock?()
    }
}
