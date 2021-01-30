//
//  BottomSheetController.swift
//  ping-pong
//
//  Created by Libor Kučera on 30.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

class BottomSheetController: UIViewController {
    typealias CloseActionBlock = (_ forced: Bool) -> Void
    var closeBlock: CloseActionBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = NSLocalizedString("Game Paused", comment: "PAUSE_MENU_TITLE")
        }
    }

    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeAction(_ sender: UIButton) {
        closeBlock?(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeBlock?(false)
    }

    override func updateViewConstraints() {
        self.view.roundedCorners(
            corners: [.topLeft, .topRight],
            radius: 25.0
        )
        super.updateViewConstraints()
    }
}
