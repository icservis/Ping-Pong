//
//  CoordinatorController+GKGameCenterControllerDelegate.swift
//  ping-pong
//
//  Created by Libor Kučera on 02.07.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import GameKit

extension CoordinatorController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
        logger.trace("GameCenter Controlled did finish presentation")
        gameCenterViewController.dismiss(animated: true) { [weak self] in
            self?.gameCenterCloseBlock?()
        }
    }
}

