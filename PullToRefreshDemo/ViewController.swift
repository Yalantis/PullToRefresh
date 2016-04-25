//
//  ViewController.swift
//  PullToRefresh
//
//  Created by Anastasiya Gorban on 5/19/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

import PullToRefresh
import UIKit

private let kPageSize = 20
class ViewController: UIViewController {
    
    @IBOutlet
    private var tableView: UITableView!
    
    private var dataSourceCount = kPageSize
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        tableView.addPullToRefresh(PullToRefresh(), action: { [weak self] in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self?.dataSourceCount = kPageSize
                self?.tableView.reloadData()
                self?.tableView.endRefreshing()
            }
        })
        
        tableView.addPullToRefresh(PullToRefresh(position: .Bottom), action: { [weak self] in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self?.dataSourceCount += kPageSize
                self?.tableView.reloadData()
                self?.tableView.endRefreshing(position: .Bottom)
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        tableView.removePullToRefresh(tableView.bottomPullToRefresh!)
        tableView.removePullToRefresh(tableView.topPullToRefresh!)
    }
    
    @IBAction
    private func startRefreshing() {
        tableView.startRefreshing()
    }
}

extension ViewController:UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

