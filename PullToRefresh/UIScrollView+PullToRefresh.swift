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
    
    internal func defaultFrame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect {
        let view = pullToRefresh.refreshView
        var originY: CGFloat
        switch pullToRefresh.position {
        case .top:
            originY = -view.frame.size.height
        case .bottom:
            originY = contentSize.height
        }
        return CGRect(x: 0, y: originY, width: frame.width, height: view.frame.height)
    }
    
    public func addPullToRefresh(_ pullToRefresh: PullToRefresh, action: @escaping () -> ()) {
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
        sendSubview(toBack: view)
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

private var topPullToRefreshInsetsHandlerKey: UInt8 = 0
private var bottomPullToRefreshInsetsHandlerKey: UInt8 = 0
private var implementationSwapedKey: UInt8 = 0

@available(iOS 11.0, *)
extension UIScrollView {
    
    private var topPullToRefreshInsetsHandler: ((UIEdgeInsets) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &topPullToRefreshInsetsHandlerKey) as? ((UIEdgeInsets) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &topPullToRefreshInsetsHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var bottomPullToRefreshInsetsHandler: ((UIEdgeInsets) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &bottomPullToRefreshInsetsHandlerKey) as? ((UIEdgeInsets) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &bottomPullToRefreshInsetsHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var isImplementationSwaped: Bool {
        get{
            return objc_getAssociatedObject(self, &implementationSwapedKey) as? Bool ?? false
        }
        set{
             objc_setAssociatedObject(self, &implementationSwapedKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    internal func addAdjustedContentInsetsHandler(forPosition position: Position, handler: @escaping ((UIEdgeInsets) -> Void)) {
        switch position {
        case .top:
            topPullToRefreshInsetsHandler = handler
        case .bottom:
            bottomPullToRefreshInsetsHandler = handler
        }
        if !isImplementationSwaped {
            swapAdjustedContentInsetDidChangeImplementation()
            isImplementationSwaped = true
        }
    }
    
    private func swapAdjustedContentInsetDidChangeImplementation() {
        let originalSelector = #selector(adjustedContentInsetDidChange)
        let swizzledSelector = #selector(patchedAdjustedContentInsetDidChange)
        
        if let originalMethod = class_getInstanceMethod(UIScrollView.self, originalSelector),
           let swizzledMethod = class_getInstanceMethod(UIScrollView.self, swizzledSelector) {
           method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    internal func removeAdjustedContentInsetsHandler(forPosition position: Position) {
        switch position {
        case .top:
            topPullToRefreshInsetsHandler = nil
        case .bottom:
            bottomPullToRefreshInsetsHandler = nil
        }
        if topPullToRefreshInsetsHandler == nil && bottomPullToRefreshInsetsHandler == nil {
            swapAdjustedContentInsetDidChangeImplementation()
            isImplementationSwaped = false
        }
    }
    
    @objc internal func patchedAdjustedContentInsetDidChange() {
        topPullToRefreshInsetsHandler?(adjustedContentInset)
        bottomPullToRefreshInsetsHandler?(adjustedContentInset)
        patchedAdjustedContentInsetDidChange()
    }
}
