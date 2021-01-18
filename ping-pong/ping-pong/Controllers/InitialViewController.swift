//
//  GameViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 03/02/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import UIKit

final class InitialViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        loadScene("IntroScene")
    }
}
