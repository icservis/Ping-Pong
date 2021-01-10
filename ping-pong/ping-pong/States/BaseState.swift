//
//  BaseState.swift
//  ping-pong
//
//  Created by Libor Kučera on 08.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import GameplayKit

class BaseState: GKState {
    unowned let scene: BaseScene

    init(scene: BaseScene) {
        self.scene = scene
        super.init()
    }
}
