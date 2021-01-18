//
//  TopPlayersViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit

class TopPlayersViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        logger.trace("TopPlayers back action")
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setTitle("BACK", for: .normal)
            backButton.tintColor = .white
        }
    }
}
