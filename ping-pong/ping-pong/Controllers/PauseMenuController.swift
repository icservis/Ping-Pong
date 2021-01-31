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
            //closeButton.titleLabel?.font = .scaledButtonFont(for: .llPixel3)
            closeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            //titleLabel.font = .scaledLabelFont(for: .llPixel3)
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

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func updateViewConstraints() {
        self.view.roundedCorners(
            corners: [.topLeft, .topRight],
            radius: 25.0
        )
        super.updateViewConstraints()
    }

    deinit {
        closeBlock?()
    }
}
