//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import UIKit
import Foundation

public protocol RefreshViewAnimator {
     func animateState(state: State)
}

// MARK: PullToRefresh

public enum Position {
    case Top, Bottom
}

public class PullToRefresh: NSObject {
    
    public var position: Position = .Top
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
        scrollView?.addObserver(self, forKeyPath: contentSizeKeyPath, options: .Initial, context: &KVOContext)
    }
    
    private func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
        scrollView?.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &KVOContext)
    }

    // MARK: - State
    
    var state: State = .Inital {
        didSet {
            animator.animateState(state)
            switch state {
            case .Loading:
                if let scrollView = scrollView where (oldValue != .Loading) {
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
            case .Finished:
                removeScrollViewObserving()
                UIView.animateWithDuration(1, delay: hideDelay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveLinear, animations: {
                    self.scrollView?.contentInset = self.scrollViewDefaultInsets
                    if case .Top = self.position {
                        self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                    }
                }, completion: { finished in
                    self.addScrollViewObserving()
                    self.state = .Inital
                })
            default: break
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(refreshView: UIView, position: Position = .Top, animator: RefreshViewAnimator) {
        self.refreshView = refreshView
        self.animator = animator
        self.position = position
    }
    
    public convenience init(position: Position = .Top) {
        let refreshView = DefaultRefreshView()
        self.init(refreshView: refreshView, position: position, animator: DefaultViewAnimator(refreshView: refreshView))
    }
    
    deinit {
        removeScrollViewObserving()
    }
    
    // MARK: KVO

    private var KVOContext = "PullToRefreshKVOContext"
    private let contentOffsetKeyPath = "contentOffset"
    private let contentSizeKeyPath = "contentSize"
    private var previousScrollViewOffset: CGPoint = CGPointZero
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            var offset: CGFloat
            switch position {
            case .Top:
                offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            case .Bottom:
                offset = scrollView!.contentSize.height - previousScrollViewOffset.y - self.scrollView!.bounds.height
            }
      
            let refreshViewHeight = refreshView.frame.size.height
            
            switch offset {
            case 0 where (state != .Loading): state = .Inital
            case -refreshViewHeight...0 where (state != .Loading && state != .Finished):
                state = .Releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == State.Releasing(progress: 1) && scrollView?.dragging == false {
                    state = .Loading
                } else if state != State.Loading && state != State.Finished {
                    state = .Releasing(progress: 1)
                }
            default: break
            }
        } else if (context == &KVOContext && keyPath == contentSizeKeyPath && object as? UIScrollView == scrollView) {
            if case .Bottom = position {
                refreshView.frame = CGRect(x: 0, y: scrollView!.contentSize.height, width: scrollView!.bounds.width, height: refreshView.bounds.height)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    // MARK: - Start/End Refreshing
    
    func startRefreshing() {
        if self.state != State.Inital {
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
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                                      Int64(0.27 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.state = State.Loading
            })
    }
    
    func endRefreshing() {
        if state == .Loading {
            state = .Finished
        }
    }
}

// MARK: - State enumeration

public enum State:Equatable, CustomStringConvertible {
    case Inital, Loading, Finished
    case Releasing(progress: CGFloat)
    
    public var description: String {
        switch self {
        case .Inital: return "Inital"
        case .Releasing(let progress): return "Releasing:\(progress)"
        case .Loading: return "Loading"
        case .Finished: return "Finished"
        }
    }
}

public func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.Inital, .Inital): return true
    case (.Loading, .Loading): return true
    case (.Finished, .Finished): return true
    case (.Releasing, .Releasing): return true
    default: return false
    }
}

// MARK: Default PullToRefresh

class DefaultRefreshView: UIView {
    private(set) var activicyIndicator: UIActivityIndicatorView!
    
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
        if (activicyIndicator == nil) {
            activicyIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activicyIndicator.hidesWhenStopped = true
            addSubview(activicyIndicator)
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        setupFrameInSuperview(superview)
    }
    
    private func setupFrameInSuperview(newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRectMake(frame.origin.x, frame.origin.y, superview.frame.width, 40)
        }
    }
    
    private func centerActivityIndicator() {
        if (activicyIndicator != nil) {
            activicyIndicator.center = convertPoint(center, fromView: superview)
        }
    }
}

class DefaultViewAnimator: RefreshViewAnimator {
    private let refreshView: DefaultRefreshView
    
    init(refreshView: DefaultRefreshView) {
        self.refreshView = refreshView
    }
    
    func animateState(state: State) {
        switch state {
        case .Inital: refreshView.activicyIndicator?.stopAnimating()
        case .Releasing(let progress):
            refreshView.activicyIndicator?.hidden = false

            var transform = CGAffineTransformIdentity
            transform = CGAffineTransformScale(transform, progress, progress);
            transform = CGAffineTransformRotate(transform, 3.14 * progress * 2);
            refreshView.activicyIndicator?.transform = transform
        case .Loading: refreshView.activicyIndicator?.startAnimating()
        default: break
        }
    }
}
