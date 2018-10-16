//
//  DefaultRefreshView.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class DefaultRefreshView: UIView {
    
    fileprivate(set) lazy var activityIndicator: UIActivityIndicatorView! = {
        #if swift(>=4.2)
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        #else
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        #endif
        self.addSubview(activityIndicator)
        return activityIndicator
    }()

    override func layoutSubviews() {
        centerActivityIndicator()
        setupFrame(in: superview)
        
        super.layoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        centerActivityIndicator()
        setupFrame(in: superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrame(in newSuperview: UIView?) {
        guard let superview = newSuperview else { return }

        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.frame.width, height: frame.height)
    }
    
     func centerActivityIndicator() {
        activityIndicator.center = convert(center, from: superview)
    }
}
