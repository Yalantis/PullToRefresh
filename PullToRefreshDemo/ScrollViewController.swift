//
//  ScrollViewController.swift
//  PullToRefreshDemo
//
//  Created by Sergey Prikhodko on 06.04.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import PullToRefresh

final class ScrollViewController: UIViewController, PullToRefreshPresentable {

    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPullToRefresh(on: scrollView)
    }
    
    @IBAction func refreshAction() {
        scrollView.startRefreshing(at: .top)
    }
    
    @IBAction func settingsAction() {
        openSettings(for: scrollView)
    }
    
    deinit {
        scrollView.removeAllPullToRefresh()
    }
}
