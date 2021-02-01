//
//  SlideInPresentationAnimator.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

class SlideInPresentationAnimator: NSObject {
    private let direction: SlideInPresentationDirection
    enum Mode {
        case presentation
        case dismissal

        var key: UITransitionContextViewControllerKey {
            switch self {
            case .presentation:
                return .to
            case .dismissal:
                return .from
            }
        }
    }
    private let mode: Mode

    init(direction: SlideInPresentationDirection, mode: Mode) {
        self.direction = direction
        self.mode = mode
    }
}

extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: mode.key) else { return }

        if case .presentation = mode {
            transitionContext.containerView.addSubview(controller.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        switch direction {
        case .leading:
            dismissedFrame.origin.x = -presentedFrame.width
        case .trailing:
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
        case .bottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        }

        let initialFrame: CGRect
        let finalFrame: CGRect
        switch mode {
        case .presentation:
            initialFrame = dismissedFrame
            finalFrame = presentedFrame
        case .dismissal:
            initialFrame = presentedFrame
            finalFrame = dismissedFrame
        }

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                controller.view.frame = finalFrame
            }, completion: { [weak self] _ in
                let finished = !transitionContext.transitionWasCancelled
                if let mode = self?.mode, case .dismissal = mode, finished {
                    controller.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            }
        )
    }
}
