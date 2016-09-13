//
//  DefaultRefreshView.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class DefaultRefreshView: UIView {
    
    fileprivate(set) var activityIndicator: UIActivityIndicatorView?

    override func layoutSubviews() {
        if activityIndicator == nil {
            activityIndicator = {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                activityIndicator.hidesWhenStopped = true
                addSubview(activityIndicator)
                return activityIndicator
            }()
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setupFrameInSuperview(superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrameInSuperview(_ newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.frame.width, height: frame.height)
        }
    }
    
     func centerActivityIndicator() {
        if let activityIndicator = activityIndicator {
            activityIndicator.center = convert(center, from: superview)
        }
    }
}
