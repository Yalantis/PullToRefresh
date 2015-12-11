//
//  AwesomeViewController.swift
//  PullToRefreshDemo
//
//  Created by race on 15/12/11.
//  Copyright © 2015年 Yalantis. All rights reserved.
//

import UIKit

class AwesomeViewController: UIViewController {

    @IBOutlet
    weak var tableView: UITableView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        tableView.addPullToRefresh(AwesomePullToRefresh(), action: { [weak self] in
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
    
}
