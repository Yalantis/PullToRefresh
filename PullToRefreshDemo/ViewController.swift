//
//  ViewController.swift
//  PullToRefresh
//
//  Created by Anastasiya Gorban on 5/19/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

import PullToRefresh
import UIKit

private let PageSize = 20

class ViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    private var dataSourceCount = PageSize
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        setupPullToRefresh()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        tableView.removePullToRefresh(tableView.bottomPullToRefresh!)
        tableView.removePullToRefresh(tableView.topPullToRefresh!)
    }
    
    @IBAction private func startRefreshing() {
        tableView.startRefreshing(at: .Top)
    }
}

private extension ViewController {
    
    func setupPullToRefresh () {
        
        
        tableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                dispatch_async(dispatch_get_main_queue()) {
                    self?.dataSourceCount = PageSize
                    self?.tableView.endRefreshing(at: .Top)
                }
            }
        }

        tableView.addPullToRefresh(PullToRefresh(position: .Bottom)) { [weak self] in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                dispatch_async(dispatch_get_main_queue()) {
                self?.dataSourceCount += PageSize
                self?.tableView.reloadData()
                self?.tableView.endRefreshing(at: .Bottom)
                }
            }
        }
    }
}

extension ViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}