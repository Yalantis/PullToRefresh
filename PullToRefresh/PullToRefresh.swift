//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import UIKit

public class PullToRefresh: NSObject {
    
    public var hideDelay: NSTimeInterval = 0

    let refreshView: UIView
    var action: (() -> ())?
    
    private let animator: RefreshViewAnimator
    
    // MARK: - ScrollView & Observing

    private var scrollViewDefaultInsets = UIEdgeInsetsZero
    weak var scrollView: UIScrollView? {
        willSet {
            removeScrollViewObserving()
        }
        didSet {
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                addScrollViewObserving()
            }
        }
    }
    
    private func addScrollViewObserving() {
        scrollView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
    }
    
    private func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }

    // MARK: - State
    
    var state: State = .Initial {
        didSet {
            animator.animateState(state)
            switch state {
            case .Loading:
                if let scrollView = scrollView where (oldValue != .Loading) {
                    scrollView.contentOffset = previousScrollViewOffset
                    scrollView.bounces = false
                    UIView.animateWithDuration(0.3, animations: {
                        let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets)
                        }, completion: { finished in
                            scrollView.bounces = true
                    })
                    
                    action?()
                }
                
            case .Finished:
                if isCurrentlyVisible() {
                    removeScrollViewObserving()
                    UIView.animateWithDuration(1, delay: hideDelay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveLinear, animations: {
                        self.scrollView?.contentInset = self.scrollViewDefaultInsets
                        self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                        }, completion: { finished in
                            self.addScrollViewObserving()
                            self.state = .Initial
                    })
                } else {
                    scrollView?.contentInset = self.scrollViewDefaultInsets
                    state = .Initial
                }
        
            default: break
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(refreshView: UIView, animator: RefreshViewAnimator, height: CGFloat) {
        self.refreshView = refreshView
        self.animator = animator
    }
    
    public convenience init(height: CGFloat = 40) {
        let refreshView = DefaultRefreshView()
        refreshView.frame.size.height = height
        self.init(refreshView: refreshView, animator: DefaultViewAnimator(refreshView: refreshView), height: height)
    }
    
    deinit {
        removeScrollViewObserving()
    }
    
    // MARK: KVO

    private var KVOContext = "PullToRefreshKVOContext"
    private let contentOffsetKeyPath = "contentOffset"
    private var previousScrollViewOffset: CGPoint = CGPointZero
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            let offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = refreshView.frame.size.height
            
            switch offset {
            case 0 where (state != .Loading): state = .Initial
            case -refreshViewHeight...0 where (state != .Loading && state != .Finished):
                state = .Releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == .Releasing(progress: 1) && scrollView?.dragging == false {
                    state = .Loading
                } else if state != .Loading && state != .Finished {
                    state = .Releasing(progress: 1)
                }
            default: break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    // MARK: - Start/End Refreshing
    
    func startRefreshing() {
        if self.state != .Initial {
            return
        }
        
        scrollView?.setContentOffset(CGPointMake(0, -refreshView.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.27 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.state = .Loading
        }
    }
    
    func endRefreshing() {
        if state == .Loading {
            state = .Finished
        }
    }
    
    // MARK: - Helpers
    
    func isCurrentlyVisible() -> Bool {
        return self.scrollView?.contentOffset.y <= -self.scrollViewDefaultInsets.top
    }
}
