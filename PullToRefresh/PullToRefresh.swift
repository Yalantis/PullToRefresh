//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import UIKit

public enum Position {
    
    case top, bottom
}

@objcMembers open class PullToRefresh: NSObject {
    
    open var position: Position = .top
    
    open var animationDuration: TimeInterval = 1
    open var hideDelay: TimeInterval = 0
    open var springDamping: CGFloat = 0.4
    open var initialSpringVelocity: CGFloat = 0.8
    open var animationOptions: UIViewAnimationOptions = [.curveLinear]

    let refreshView: UIView
    var action: (() -> ())?
    
    fileprivate var observations: [NSKeyValueObservation] = []
    fileprivate let animator: RefreshViewAnimator
    
    // MARK: - ScrollView & Observing

    fileprivate var scrollViewDefaultInsets: UIEdgeInsets = .zero
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
    
    open fileprivate(set) var state: State = .initial {
        didSet {
            animator.animate(state)
            switch state {
            case .loading:
                if oldValue != .loading {
                    animateLoadingState()
                }
                
            case .finished:
                if isCurrentlyVisible() {
                    animateFinishedState()
                } else {
                    scrollView?.contentInset = self.scrollViewDefaultInsets
                    state = .initial
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
    
    public convenience init(height: CGFloat = 40, position: Position = .top) {
        let refreshView = DefaultRefreshView()
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        refreshView.autoresizingMask = [.flexibleWidth]
        refreshView.frame.size.height = height
        self.init(refreshView: refreshView, animator: DefaultViewAnimator(refreshView: refreshView), height: height, position: position)
    }
    
    // MARK: KVO

    fileprivate var previousScrollViewOffset: CGPoint = CGPoint.zero

    fileprivate func addScrollViewObserving() {
        guard let scrollView = scrollView, self.observations.isEmpty else {
            return
        }
        
        self.observations.append(scrollView.observe(\.contentOffset) { (scrollView, _) in
          self.processOffsetChange(inScrollView: scrollView)
        })
        
        self.observations.append(scrollView.observe(\.contentSize) { (scrollView, _) in
            if case .bottom = self.position {
                self.refreshView.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.width, height: self.refreshView.bounds.height)
            }
            self.previousScrollViewOffset.y = scrollView.contentOffset.y
        })
        
        self.observations.append(scrollView.observe(\.contentOffset) { (scrollView, _) in
            if self.state == .initial {
                self.scrollViewDefaultInsets = scrollView.contentInset
            }
            self.previousScrollViewOffset.y = scrollView.contentOffset.y
        })
     }
    
    func processOffsetChange(inScrollView scrollView: UIScrollView) {
        var offset: CGFloat
        switch self.position {
        case .top:
            offset = self.previousScrollViewOffset.y + self.scrollViewDefaultInsets.top
            
        case .bottom:
            if scrollView.contentSize.height > scrollView.bounds.height {
                offset = scrollView.contentSize.height - self.previousScrollViewOffset.y - scrollView.bounds.height
            } else {
                offset = scrollView.contentSize.height - self.previousScrollViewOffset.y
            }
        }
        let refreshViewHeight = self.refreshView.frame.size.height
        
        switch offset {
        case 0 where (self.state != .loading): self.state = .initial
        case -refreshViewHeight...0 where (self.state != .loading && self.state != .finished):
            self.state = .releasing(progress: -offset / refreshViewHeight)
            
        case -1000...(-refreshViewHeight):
            if self.state == .releasing(progress: 1) && scrollView.isDragging == false {
                self.state = .loading
            } else if self.state != .loading && self.state != .finished {
                self.state = .releasing(progress: 1)
            }
        default: break
        }
        self.previousScrollViewOffset.y = scrollView.contentOffset.y
    }
    
    fileprivate func removeScrollViewObserving() {
        self.observations.forEach({$0.invalidate()})
        self.observations = []
    }
}

// MARK: - Start/End Refreshin
extension PullToRefresh {
    
    func startRefreshing() {
        if self.state != .initial {
            return
        }
        
        var offsetY: CGFloat
        switch position {
        case .top:
            offsetY = -refreshView.frame.height - scrollViewDefaultInsets.top
            
        case .bottom:
            offsetY = scrollView!.contentSize.height + refreshView.frame.height + scrollViewDefaultInsets.bottom - scrollView!.bounds.height
        }
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        let delayTime = DispatchTime.now() + Double(Int64(0.27 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
            self?.state = .loading
        }
    }
    
    func endRefreshing() {
        if state == .loading {
            state = .finished
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
        UIView.animate(
            withDuration: 0.3,
            animations: {
                switch self.position {
                case .top:
                    let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                    scrollView.contentInset.top = insets
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets)
                    
                case .bottom:
                    let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.bottom
                    scrollView.contentInset.bottom = insets
                }
            },
            completion: { _ in
                scrollView.bounces = true
            }
        )
        
        action?()
    }
    
    func animateFinishedState() {
        removeScrollViewObserving()
        UIView.animate(
            withDuration: animationDuration,
            delay: hideDelay,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: animationOptions,
            animations: {
                self.scrollView?.contentInset = self.scrollViewDefaultInsets
                if case .top = self.position {
                    self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                }
            },
            completion: { _ in
                self.addScrollViewObserving()
                self.state = .initial
            }
        )
    }
}

// MARK: - Helpers
private extension PullToRefresh {
    
    func isCurrentlyVisible() -> Bool {
        guard let scrollView = scrollView else { return false }
        
        return scrollView.contentOffset.y <= -scrollViewDefaultInsets.top
    }
}
