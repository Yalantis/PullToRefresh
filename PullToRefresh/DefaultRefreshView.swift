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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 40)
    }
    
    override func layoutSubviews() {
        if (activityIndicator == nil) {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator!.hidesWhenStopped = true
            addSubview(activityIndicator!)
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        setupFrameInSuperview(superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrameInSuperview(newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRectMake(frame.origin.x, frame.origin.y, superview.frame.width, 40)
        }
    }
    
     func centerActivityIndicator() {
        if let activityIndicator = activityIndicator {
            activityIndicator.center = convertPoint(center, fromView: superview)
        }
    }
}
