//
//  DefaultViewAnimator.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class DefaultViewAnimator: RefreshViewAnimator {
    
    private let refreshView: DefaultRefreshView
    
    init(refreshView: DefaultRefreshView) {
        self.refreshView = refreshView
    }
    
    func animateState(state: State) {
        switch state {
        case .Initial:
            refreshView.activityIndicator?.stopAnimating()
            
        case .Releasing(let progress):
            refreshView.activityIndicator?.hidden = false
            
            var transform = CGAffineTransformIdentity
            transform = CGAffineTransformScale(transform, progress, progress)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) * progress * 2)
            refreshView.activityIndicator?.transform = transform
            
        case .Loading:
            refreshView.activityIndicator?.startAnimating()
            
        default: break
        }
    }
}