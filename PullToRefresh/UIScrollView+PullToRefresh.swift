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

private var topPullToRefreshKey: UInt8 = 0
private var bottomPullToRefreshKey: UInt8 = 0

public extension UIScrollView {
    
    fileprivate(set) var topPullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &topPullToRefreshKey) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &topPullToRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate(set) var bottomPullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &bottomPullToRefreshKey) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &bottomPullToRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addPullToRefresh(_ pullToRefresh: PullToRefresh, action: @escaping () -> ()) {
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        var originY: CGFloat
        let view = pullToRefresh.refreshView
        
        switch pullToRefresh.position {
        case .top:
            if let previousPullToRefresh = topPullToRefresh {
                removePullToRefresh(previousPullToRefresh)
            }
            
            topPullToRefresh = pullToRefresh
            originY = -view.frame.size.height
            
        case .bottom:
            if let previousPullToRefresh = bottomPullToRefresh{
                removePullToRefresh(previousPullToRefresh)
            }
            
            bottomPullToRefresh = pullToRefresh
            originY = contentSize.height
        }
        
        view.frame = CGRect(x: 0, y: originY, width: frame.width, height: view.frame.height)
        
        addSubview(view)
        sendSubview(toBack: view)
    }
    
    func removePullToRefresh(_ pullToRefresh: PullToRefresh) {
        switch pullToRefresh.position {
        case .top:
            topPullToRefresh?.refreshView.removeFromSuperview()
            topPullToRefresh = nil
            
        case .bottom:
            bottomPullToRefresh?.refreshView.removeFromSuperview()
            bottomPullToRefresh = nil
        }
    }
    
    func startRefreshing(at position: Position) {
        switch position {
        case .top:
            topPullToRefresh?.startRefreshing()
            
        case .bottom:
            bottomPullToRefresh?.startRefreshing()
        }
    }
    
    func endRefreshing(at position: Position) {
        switch position {
        case .top:
            topPullToRefresh?.endRefreshing()
            
        case .bottom:
            bottomPullToRefresh?.endRefreshing()
        }
    }
}
