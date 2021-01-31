//
//  SlideInPresentationCoordinator.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

class SlideInPresentationCoordinator: NSObject {
    var direction: SlideInPresentationDirection = .bottom
    var proportion: CGFloat = 0.4
    var disableCompactHeight = false
}

extension SlideInPresentationCoordinator: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            direction: direction,
            proportion: proportion
        )
        presentationController.delegate = self
        return presentationController
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, isPresentation: true)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, isPresentation: false)
    }
}

extension SlideInPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
            return .overFullScreen
        } else {
            return .none
        }
    }

    /*
    func presentationController(
        _ controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle
    ) -> UIViewController? {

    }
     */
}
