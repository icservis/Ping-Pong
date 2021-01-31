//
//  SlideInPresentationController.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    private let direction: SlideInPresentationDirection
    private let proportion: CGFloat

    lazy private var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        direction: SlideInPresentationDirection,
        proportion: CGFloat
    ) {
        self.direction = direction
        self.proportion = proportion.clamped(to: 0...1)
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.setupDimmingView()
    }

    private func setupDimmingView() {
        let recogniser = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        dimmingView.addGestureRecognizer(recogniser)
    }

    @objc private func handleTap() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView else { return }
        containerView.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        coordinator.animate(
            alongsideTransition: { (context) in
                self.dimmingView.alpha = 1.0
            },
            completion: nil
        )
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        dimmingView.removeFromSuperview()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        coordinator.animate(
            alongsideTransition: { (context) in
                self.dimmingView.alpha = 0.0
            },
            completion: nil
        )
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        switch direction {
        case .leading, .trailing:
            return CGSize(
                width: parentSize.width * proportion,
                height: parentSize.height
            )
        case .top, .bottom:
            return CGSize(
                width: parentSize.width,
                height: parentSize.height * proportion
            )
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        guard let containerView = containerView else {
            return frame
        }
        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )
        switch direction {
        case .trailing:
            frame.origin.x = containerView.frame.width * (1.0 - proportion)
        case .bottom:
            frame.origin.y = containerView.frame.height * (1.0 - proportion)
        default:
            frame.origin = .zero
        }
        return frame
    }
}
