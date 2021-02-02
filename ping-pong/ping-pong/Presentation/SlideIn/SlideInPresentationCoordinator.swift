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
    var proportion: SlideInPresentationProportion = .normal
    var dimmingEffect: SlideInPresentationDimmingEffect = .dimming
    var disableCompactVerticalSize = false

    weak var interactionController: UIPercentDrivenInteractiveTransition?
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
            proportion: proportion,
            dimmingEffect: dimmingEffect
        )
        presentationController.delegate = self
        return presentationController
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, phase: .presentation)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, phase: .dismissal)
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

extension SlideInPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactVerticalSize {
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
