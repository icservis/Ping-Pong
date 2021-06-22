//
//  IntroViewController.swift
//  ping-pong
//
//  Created by Libor Kučera on 30.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

final class IntroController: BaseViewController {
    @IBOutlet weak var backgroundView: UIImageView!

    @IBOutlet weak var logoView: UIView!

    private var animatedHeightConstraintConstant: CGFloat = 0
    @IBOutlet weak var animatedHeightConstraint: NSLayoutConstraint! {
        didSet {
            animatedHeightConstraintConstant = animatedHeightConstraint.constant
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        animatedHeightConstraint.constant = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
    }

    private func start() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.25,
            initialSpringVelocity: 3,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: {
                self.animatedHeightConstraint.constant = self.animatedHeightConstraintConstant
                self.view.layoutIfNeeded()
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.logger.trace("Load MainMenu")
                    self.coordinator?.loadMainMenu()
                }
            }
        )
    }
}
