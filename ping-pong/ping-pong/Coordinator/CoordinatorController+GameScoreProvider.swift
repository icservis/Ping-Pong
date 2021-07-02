//
//  CoordinatorController+GameScoreProvider.swift
//  ping-pong
//
//  Created by Libor Kučera on 02.07.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

extension CoordinatorController: GameScoreProvider {
    func saveScore(
        _ result: GameResult,
        completion: GameScoreCompletionBlock?
    ) {
        saveScoreToGameCenter(
            result: result,
            completion: completion
        )
    }
}
