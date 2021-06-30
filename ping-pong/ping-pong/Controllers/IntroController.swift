//
//  IntroViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 30.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit
import AVFoundation

final class IntroController: BaseViewController {
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var logoView: UIView!

    private var animatedHeightConstraintConstant: CGFloat = 0
    @IBOutlet weak var animatedHeightConstraint: NSLayoutConstraint! {
        didSet {
            animatedHeightConstraintConstant = animatedHeightConstraint.constant
        }
    }

    var pianoSound = URL(fileURLWithPath: Bundle.main.path(forResource: "big-bounce", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        animatedHeightConstraint.constant = 0

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pianoSound)
        } catch {
            self.logger.error("Audio error: \(error)")
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
        audioPlayer.play()
    }

    private func start() {
        UIView.animate(
            withDuration: 2,
            delay: 0,
            usingSpringWithDamping: 0.25,
            initialSpringVelocity: 3,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: {
                self.animatedHeightConstraint.constant = self.animatedHeightConstraintConstant
                self.view.layoutIfNeeded()
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let self = self else { return }
                    self.logger.trace("Load MainMenu")
                    self.coordinator?.loadMainMenu()
                }
            }
        )
    }
}
