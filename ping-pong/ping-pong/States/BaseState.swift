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

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        debugPrint("\(self) will exit to: \(nextState)")
    }

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        if let previousState = previousState {
            debugPrint("\(self) did enter from: \(previousState)")
        } else {
            debugPrint("\(self) did enter from none")
        }
    }
}
