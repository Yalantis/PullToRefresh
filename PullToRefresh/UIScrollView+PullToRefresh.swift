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
    
    func addPullToRefresh(_ pullToRefresh: PullToRefresh, action: @escaping () -> ()) {
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        let view = pullToRefresh.refreshView
        
        switch pullToRefresh.position {
        case .top:
            removePullToRefresh(at: .top)
            topPullToRefresh = pullToRefresh
            
        case .bottom:
            removePullToRefresh(at: .bottom)
            bottomPullToRefresh = pullToRefresh
        }
        
        view.frame = defaultFrame(forPullToRefresh: pullToRefresh)
        
        addSubview(view)
        #if swift(>=4.2)
        sendSubviewToBack(view)
        #else
        sendSubview(toBack: view)
        #endif
    }
    
    func refresher(at position: Position) -> PullToRefresh? {
        switch position {
        case .top:
            return topPullToRefresh
            
        case .bottom:
            return bottomPullToRefresh
        }
    }
    
    func removePullToRefresh(at position: Position) {
        switch position {
        case .top:
            topPullToRefresh?.refreshView.removeFromSuperview()
            topPullToRefresh = nil
            
        case .bottom:
            bottomPullToRefresh?.refreshView.removeFromSuperview()
            bottomPullToRefresh = nil
        }
    }
    
    func removeAllPullToRefresh() {
        removePullToRefresh(at: .top)
        removePullToRefresh(at: .bottom)
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
    
    func endAllRefreshing() {
        endRefreshing(at: .top)
        endRefreshing(at: .bottom)
    }
    
}

internal func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(
        top: lhs.top - rhs.top,
        left: lhs.left - rhs.left,
        bottom: lhs.bottom - rhs.bottom,
        right: lhs.right - rhs.right
    )
}

internal extension UIScrollView {
    
    var normalizedContentOffset: CGPoint {
        get {
            let contentOffset = self.contentOffset
            let contentInset = self.effectiveContentInset
            
            let output = CGPoint(x: contentOffset.x + contentInset.left, y: contentOffset.y + contentInset.top)
            return output
        }
    }
    
    var effectiveContentInset: UIEdgeInsets {
        get {
            if #available(iOS 11, *) {
                return adjustedContentInset
            } else {
                return contentInset
            }
        }
        
        set {
            if #available(iOS 11.0, *), contentInsetAdjustmentBehavior != .never {
                contentInset = newValue - safeAreaInsets
            } else {
                contentInset = newValue
            }
        }
    }
    
    func defaultFrame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect {
        let view = pullToRefresh.refreshView
        var originY: CGFloat
        switch pullToRefresh.position {
        case .top:
            originY = -view.frame.size.height
        case .bottom:
            originY = contentSize.height
        }
        let height = view.frame.height + (pullToRefresh.topPadding ?? 0)
        return CGRect(x: 0, y: originY, width: frame.width, height: height)
    }

}
