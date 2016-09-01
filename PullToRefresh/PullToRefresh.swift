//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import UIKit

public enum Position {
    
    case Top, Bottom
}

public class PullToRefresh: NSObject {
    
    public var position: Position = .Top
    
    public var animationDuration: NSTimeInterval = 1
    public var hideDelay: NSTimeInterval = 0
    public var springDamping: CGFloat = 0.4
    public var initialSpringVelocity: CGFloat = 0.8
    public var animationOptions: UIViewAnimationOptions = [.CurveLinear]

    let refreshView: UIView
    var action: (() -> ())?
    
    private var isObserving = false
    
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
    
    // MARK: - State
    
    public private(set) var state: State = .Initial {
        didSet {
            animator.animateState(state)
            switch state {
            case .Loading:
                if oldValue != .Loading {
                    animateLoadingState()
                }
                
            case .Finished:
                if isCurrentlyVisible() {
                    animateFinishedState()
                } else {
                    scrollView?.contentInset = self.scrollViewDefaultInsets
                    state = .Initial
                }
        
            default: break
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(refreshView: UIView, animator: RefreshViewAnimator, height: CGFloat, position: Position) {
        self.refreshView = refreshView
        self.animator = animator
        self.position = position
    }
    
    public convenience init(height: CGFloat = 40, position: Position = .Top) {
        let refreshView = DefaultRefreshView()
        refreshView.frame.size.height = height
        self.init(refreshView: refreshView, animator: DefaultViewAnimator(refreshView: refreshView), height: height, position: position)
    }
    
    deinit {
        removeScrollViewObserving()
    }
    
    // MARK: KVO

    private var KVOContext = "PullToRefreshKVOContext"
    private let contentOffsetKeyPath = "contentOffset"
    private let contentInsetKeyPath = "contentInset"
    private let contentSizeKeyPath = "contentSize"
    private var previousScrollViewOffset: CGPoint = CGPointZero
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            var offset: CGFloat
            switch position {
            case .Top:
                offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
                
            case .Bottom:
                if scrollView!.contentSize.height > scrollView!.bounds.height {
                    offset = scrollView!.contentSize.height - previousScrollViewOffset.y - scrollView!.bounds.height
                } else {
                    offset = scrollView!.contentSize.height - previousScrollViewOffset.y
                }
            }
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
        } else if (context == &KVOContext && keyPath == contentSizeKeyPath && object as? UIScrollView == scrollView) {
            if case .Bottom = position {
                refreshView.frame = CGRect(x: 0, y: scrollView!.contentSize.height, width: scrollView!.bounds.width, height: refreshView.bounds.height)
            }
        } else if (context == &KVOContext && keyPath == contentInsetKeyPath && object as? UIScrollView == scrollView) {
            if self.state == .Initial {
                scrollViewDefaultInsets = scrollView!.contentInset
            }
          
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView?.contentOffset.y ?? 0
    }
    
    private func addScrollViewObserving() {
        guard let scrollView = scrollView where !isObserving else {
            return
        }
        
        scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
        scrollView.addObserver(self, forKeyPath: contentSizeKeyPath, options: .Initial, context: &KVOContext)
        scrollView.addObserver(self, forKeyPath: contentInsetKeyPath, options: .New, context: &KVOContext)
      
        isObserving = true
    }
    
    private func removeScrollViewObserving() {
        guard let scrollView = scrollView where isObserving else {
            return
        }
        
        scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
        scrollView.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &KVOContext)
        scrollView.removeObserver(self, forKeyPath: contentInsetKeyPath, context: &KVOContext)
      
        isObserving = false
    }
}

// MARK: - Start/End Refreshin
extension PullToRefresh {
    
    func startRefreshing() {
        if self.state != .Initial {
            return
        }
        
        var offsetY: CGFloat
        switch position {
        case .Top:
            offsetY = -refreshView.frame.height - scrollViewDefaultInsets.top
            
        case .Bottom:
            offsetY = scrollView!.contentSize.height + refreshView.frame.height + scrollViewDefaultInsets.bottom - scrollView!.bounds.height
        }
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
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
}

// MARK: - Animate scroll view
private extension PullToRefresh {
    
    func animateLoadingState() {
        guard let scrollView = scrollView else {
            return
        }
        
        scrollView.contentOffset = previousScrollViewOffset
        scrollView.bounces = false
        UIView.animateWithDuration(0.3, animations: {
            switch self.position {
            case .Top:
                let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                scrollView.contentInset.top = insets
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets)
                
            case .Bottom:
                let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.bottom
                scrollView.contentInset.bottom = insets
            }
            }, completion: { finished in
                scrollView.bounces = true
        })
        
        action?()
    }
    
    func animateFinishedState() {
        removeScrollViewObserving()
        UIView.animateWithDuration(
            animationDuration,
            delay: hideDelay,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: animationOptions,
            animations: {
                self.scrollView?.contentInset = self.scrollViewDefaultInsets
                if case .Top = self.position {
                    self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                }
            }, completion: { finished in
                self.addScrollViewObserving()
                self.state = .Initial
        })
    }
}

// MARK: - Helpers
private extension PullToRefresh {
    
    func isCurrentlyVisible() -> Bool {
        return self.scrollView?.contentOffset.y <= -self.scrollViewDefaultInsets.top
    }
}
