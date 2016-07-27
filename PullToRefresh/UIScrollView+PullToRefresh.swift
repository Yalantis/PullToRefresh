//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import Foundation
import UIKit
import ObjectiveC

private var associatedObjectHandle: UInt8 = 0

public extension UIScrollView {
    
    private(set) var pullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectHandle) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addPullToRefresh(pullToRefresh: PullToRefresh, action: () -> ()) {
        if let previousPullToRefresh = self.pullToRefresh  {
            self.removePullToRefresh(previousPullToRefresh)
        }
        
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        self.pullToRefresh = pullToRefresh
        
        let view = pullToRefresh.refreshView
        view.frame = CGRectMake(0, -view.frame.size.height, self.frame.size.width, view.frame.size.height)
        addSubview(view)
        sendSubviewToBack(view)
    }
    
    func removePullToRefresh(pullToRefresh: PullToRefresh) {
        self.pullToRefresh?.refreshView.removeFromSuperview()
        self.pullToRefresh = nil
    }
    
    func startRefreshing() {
        pullToRefresh?.startRefreshing()
    }
    
    func endRefreshing() {
        pullToRefresh?.endRefreshing()
    }
}
