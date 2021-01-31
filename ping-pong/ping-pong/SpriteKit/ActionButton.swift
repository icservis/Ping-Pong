//
//  ActionButton.swift
//  ping-pong
//
//  Created by Libor Kučera on 07/04/2019.
//  Copyright © 2019 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import SpriteKit

class ActionButton: SKSpriteNode {
    enum NodeState {
        case active
        case selected
        case hidden
    }

    var onStateChange: ((NodeState) -> Void)?

    var state: NodeState = .active {
        didSet {
            switch state {
            case .active:
                isUserInteractionEnabled = true
                alpha = 1.0
            case .selected:
                isUserInteractionEnabled = true
                alpha = 0.75
            case .hidden:
                isUserInteractionEnabled = false
                alpha = 0.0
            }
            onStateChange?(state)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .selected
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .active
    }
}
