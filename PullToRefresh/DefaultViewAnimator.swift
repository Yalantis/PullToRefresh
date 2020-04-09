//
//  DefaultViewAnimator.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class DefaultViewAnimator: RefreshViewAnimator {
    
    fileprivate let refreshView: DefaultRefreshView
    
    init(refreshView: DefaultRefreshView) {
        self.refreshView = refreshView
    }
    
    func animate(_ state: State) {
        switch state {
        case .initial:
            refreshView.activityIndicator.stopAnimating()
            
        case .releasing(let progress):
            transform(to: progress)
            
        case .loading:
            transform(to: 1.0)
            refreshView.activityIndicator.startAnimating()
            
        default: break
        }
    }
    
    private func transform(to progress: CGFloat) {
        refreshView.activityIndicator.isHidden = false
        
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: progress, y: progress)
        transform = transform.rotated(by: CGFloat(Double.pi) * progress * 2)
        refreshView.activityIndicator.transform = transform
    }
}
