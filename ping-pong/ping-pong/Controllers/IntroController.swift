//
//  IntroViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 30.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

final class IntroController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var skipButton: UIButton!

    @IBAction func skipAction(_ sender: UIButton) {
        logger.trace("Load MainMenu")
        coordinator?.loadMainMenu()
    }
}
