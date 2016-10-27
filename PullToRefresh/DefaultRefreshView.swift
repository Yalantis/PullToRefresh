//
//  DefaultRefreshView.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class DefaultRefreshView: UIView {
    
    private(set) var activityIndicator: UIActivityIndicatorView?

    override func layoutSubviews() {
        if activityIndicator == nil {
            activityIndicator = {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                activityIndicator.hidesWhenStopped = true
                addSubview(activityIndicator)
                return activityIndicator
            }()
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        centerActivityIndicator()
        setupFrameInSuperview(superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrameInSuperview(newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRectMake(frame.origin.x, frame.origin.y, superview.frame.width, frame.height)
        }
    }
    
     func centerActivityIndicator() {
        if let activityIndicator = activityIndicator {
            activityIndicator.center = convertPoint(center, fromView: superview)
        }
    }
}
