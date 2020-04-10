//
//  TableViewController.swift
//  PullToRefresh
//
//  Created by Anastasiya Gorban on 5/19/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

import PullToRefresh
import UIKit

private let PageSize = 20

final class TableViewController: UIViewController, PullToRefreshPresentable {
    
    @IBOutlet fileprivate var tableView: UITableView!
    fileprivate var dataSourceCount = PageSize
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPullToRefresh(on: tableView)
    }
    
    @IBAction func refreshAction() {
        tableView.startRefreshing(at: .top)
    }
    
    @IBAction func openSettings() {
        openSettings(for: tableView)
    }
    
    func loadAction() {
        dataSourceCount += PageSize
        tableView.reloadData()
    }
    
    func reloadAction() {
        dataSourceCount = PageSize
    }
    
    deinit {
        tableView.removeAllPullToRefresh()
    }
}

extension TableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        
        return cell
    }
}
