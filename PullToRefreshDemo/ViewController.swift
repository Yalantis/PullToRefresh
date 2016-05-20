//
//  ViewController.swift
//  PullToRefresh
//
//  Created by Anastasiya Gorban on 5/19/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

import PullToRefresh
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet
    private var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let pullToRefresh = PullToRefresh()

        // Uncomment to view simple animation customizations
//        let refreshView = DefaultRefreshView()
//        let animator = DefaultViewAnimator(refreshView: refreshView)
//        animator.loadingAnimationDuration = 0.6
//        animator.finishedAnimationDuration = 2.0
//        animator.finishedAnimationSpringVelocity = 1.6
//
//        let customPullToRefresh = PullToRefresh(refreshView: refreshView, animator: animator)

        tableView.addPullToRefresh(pullToRefresh, action: { [weak self] in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self?.tableView.endRefreshing()
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        tableView.removePullToRefresh(tableView.pullToRefresh!)
    }
    
    @IBAction
    private func startRefreshing() {
        tableView.startRefreshing()
    }
}

