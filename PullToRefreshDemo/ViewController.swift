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
    
    @IBOutlet fileprivate var tableView: UITableView!
    fileprivate var dataSourceCount = PageSize
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPullToRefresh()
    }
    
    deinit {
        tableView.removePullToRefresh(tableView.bottomPullToRefresh!)
        tableView.removePullToRefresh(tableView.topPullToRefresh!)
    }
    
    @IBAction fileprivate func startRefreshing() {
        tableView.startRefreshing(at: .top)
    }
}

private extension ViewController {
    
    func setupPullToRefresh() {
        tableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount = PageSize
                self?.tableView.endRefreshing(at: .top)
            }
        }
        
        tableView.addPullToRefresh(PullToRefresh(position: .bottom)) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount += PageSize
                self?.tableView.reloadData()
                self?.tableView.endRefreshing(at: .bottom)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        return cell
    }
}
