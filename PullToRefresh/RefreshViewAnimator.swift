//
//  RefreshViewAnimator.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public protocol RefreshViewAnimator {
    
    func animate(_ state: State)
}
