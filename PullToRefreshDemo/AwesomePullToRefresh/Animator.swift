//
//  Animator.swift
//  PullToRefreshDemo
//
//  Created by race on 15/12/10.
//  Copyright © 2015年 Yalantis. All rights reserved.
//

import PullToRefresh

class Animator: RefreshViewAnimator {
    private let refreshView: RefreshView
    private var isArrowStateUp: Bool = false
    private var isAnimating: Bool = false

    init(refreshView: RefreshView) {
        self.refreshView = refreshView
    }

    func animateState(state: State) {

        switch state {
        case .Inital:
            refreshView.arrowImage.transform = CGAffineTransformIdentity
            refreshView.arrowImage.hidden = false
            refreshView.indicatorView.stopAnimating()
            refreshView.tipLabel.text = "Pull to refresh"
        case .Releasing(let progress) where (isAnimating == false):
            if progress >= 1 && !isArrowStateUp {
                isArrowStateUp = true
                isAnimating = true
                self.refreshView.tipLabel.text = "Ready to refresh"
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.refreshView.arrowImage.transform = CGAffineTransformMakeRotation(-CGFloat(3 * M_PI))
                    }, completion: { _ in
                        self.isAnimating = false
                })
            } else if progress < 1 && isArrowStateUp {
                isArrowStateUp = false
                isAnimating = true
                self.refreshView.tipLabel.text = "Pull to refresh"
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.refreshView.arrowImage.transform = CGAffineTransformMakeRotation(CGFloat(0))
                    }, completion: { _ in
                    self.isAnimating = false
                })
            }
        case .Loading:
            refreshView.indicatorView.hidden = false
            refreshView.arrowImage.hidden = true
            refreshView.indicatorView.startAnimating()
            refreshView.tipLabel.text = "Loading"
        default: break
        }
    }
}
