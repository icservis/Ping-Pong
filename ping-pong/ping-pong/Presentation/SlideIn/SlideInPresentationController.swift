//
//  SlideInPresentationController.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

enum SlideInPresentationDirection {
    case top
    case left
    case bottom
    case right
}

enum SlideInPresentationProportion {
    typealias Value = CGFloat
    case normal
    case full
    case value(Value)

    init?(value: Value) {
        let range: ClosedRange<Value> = (0...1)
        precondition(range.contains(value))
        self = SlideInPresentationProportion.value(value)
    }

    var value: Value {
        switch self {
        case .normal:
            return 0.45
        case .full:
            return 0.95
        case let .value(value):
            return value
        }
    }

    var reversedValue: Value {
        return 1 - self.value
    }
}

enum SlideInPresentationDimmingEffect {
    case dimming
    case blur(style: UIBlurEffect.Style)
}

enum SlideInPresentationTransitionPhase {
    case presentation
    // case management
    case dismissal
}


class SlideInPresentationController: UIPresentationController {
    private let direction: SlideInPresentationDirection
    private let proportion: SlideInPresentationProportion
    private let dimmingEffect: SlideInPresentationDimmingEffect

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        direction: SlideInPresentationDirection,
        proportion: SlideInPresentationProportion,
        dimmingEffect: SlideInPresentationDimmingEffect
    ) {
        self.direction = direction
        self.proportion = proportion
        self.dimmingEffect = dimmingEffect
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.setupTapGesture()
        self.setupPanGesture()
    }

    private var interactionController: UIPercentDrivenInteractiveTransition? {
        didSet {
            guard let coordinator = presentedViewController.transitioningDelegate as? SlideInPresentationCoordinator else { return }
            coordinator.interactionController = interactionController
        }
    }

    lazy private var dimmingView: UIView = {
        guard case .dimming = dimmingEffect else { fatalError() }
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    private var blurView: UIVisualEffectView {
        guard case let .blur(style) = dimmingEffect else { fatalError() }
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = .clear
        blurView.alpha = 1.0
        return blurView
    }

    private func setupTapGesture() {
        let recogniser = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )

        switch dimmingEffect {
        case .dimming:
            dimmingView.addGestureRecognizer(recogniser)
        case .blur:
            blurView.addGestureRecognizer(recogniser)
        }
    }

    @objc private func handleTap() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    private func setupPanGesture() {
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        presentedViewController.view.addGestureRecognizer(recogniser)
    }

    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent: CGFloat
        switch direction {
        case .left:
            percent = 1 - translate.x / gesture.view!.bounds.size.width
        case .right:
            percent = translate.x / gesture.view!.bounds.size.width
        case .top:
            percent = 1 - translate.y / gesture.view!.bounds.size.height
        case .bottom:
            percent = translate.y / gesture.view!.bounds.size.height
        }

        if gesture.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            presentingViewController.dismiss(animated: true, completion: nil)
        } else if gesture.state == .changed {
            interactionController?.update(percent)
        } else if gesture.state == .cancelled {
            interactionController?.cancel()
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: gesture.view)
            if (percent > 0.5 && velocity.y == 0) || velocity.y > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView else { return }
        switch dimmingEffect {
        case .dimming:
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            containerView.insertSubview(dimmingView, at: 0)

            NSLayoutConstraint.activate([
                dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
                dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        case .blur:
            blurView.translatesAutoresizingMaskIntoConstraints = false
            containerView.insertSubview(blurView, at: 0)

            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
                blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        }

        guard let coordinator = presentedViewController.transitionCoordinator else {
            if case .dimming = dimmingEffect {
                dimmingView.alpha = 1.0
            }
            return
        }
        coordinator.animate(
            alongsideTransition: { (context) in
                if case .dimming = self.dimmingEffect {
                    self.dimmingView.alpha = 1.0
                }
            },
            completion: nil
        )
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        if !completed {
            switch dimmingEffect {
            case .dimming:
                dimmingView.removeFromSuperview()
            case .blur:
                blurView.removeFromSuperview()
            }
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            if case .dimming = dimmingEffect {
                dimmingView.alpha = 0.0
            }
            return
        }
        coordinator.animate(
            alongsideTransition: { (context) in
                if case .dimming = self.dimmingEffect {
                    self.dimmingView.alpha = 0.0
                }
            },
            completion: nil
        )
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            switch dimmingEffect {
            case .dimming:
                self.dimmingView.removeFromSuperview()
            case .blur:
                self.blurView.removeFromSuperview()
            }
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(
                width: parentSize.width * proportion.value,
                height: parentSize.height
            )
        case .top, .bottom:
            return CGSize(
                width: parentSize.width,
                height: parentSize.height * proportion.value
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
        case .right:
            frame.origin.x = containerView.frame.width * proportion.reversedValue
        case .bottom:
            frame.origin.y = containerView.frame.height * proportion.reversedValue
        default:
            frame.origin = .zero
        }
        return frame
    }
}
