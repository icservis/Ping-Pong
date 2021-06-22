//
//  LeaderBoard.swift
//  ping-pong
//
//  Created by Libor Kučera on 20.06.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation
import Logging

enum LeaderBoard {
    case weeklyAllStars
    case topByLevel(Player.Difficulty)

    var identifier: String {
        switch self {
        case .weeklyAllStars:
            return "allstars_weekly"
        case let .topByLevel(level):
            return level.leaderBoardId
        }
    }
}

extension Player.Difficulty {
    var leaderBoardId: String {
        switch self {
        case .easy:
            return "top_easy"
        case .medium:
            return "top_medium"
        case .hard:
            return "top_hard"
        }
    }
}
