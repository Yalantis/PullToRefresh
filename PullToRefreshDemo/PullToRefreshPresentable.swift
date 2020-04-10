//
//  BaseViewController.swift
//  PullToRefreshDemo
//
//  Created by Sergey Prikhodko on 07.04.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import PullToRefresh

protocol PullToRefreshPresentable: class {
    
    func loadAction()
    func reloadAction()
    
    func setupPullToRefresh(on scrollView: UIScrollView)
    func openSettings(for scrollView: UIScrollView)
}

// MARK: - PullToRefresh

extension PullToRefreshPresentable {
    
    func setupPullToRefresh(on scrollView: UIScrollView) {
        
        scrollView.addPullToRefresh(PullToRefresh()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self, weak scrollView] in
                self?.reloadAction()
                scrollView?.endRefreshing(at: .top)
            }
        }
        
        scrollView.addPullToRefresh(PullToRefresh(position: .bottom)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self, weak scrollView] in
                self?.loadAction()
                scrollView?.endRefreshing(at: .bottom)
            }
        }
    }
    
    func loadAction() {}
    func reloadAction() {}
}

// MARK: - Open Settings

extension PullToRefreshPresentable where Self: UIViewController {
    
    func openSettings(for scrollView: UIScrollView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "\(SettingViewController.self)") as! SettingViewController
        controller.scrollView = scrollView
        let navigation = UINavigationController(rootViewController: controller)

        navigationController?.present(navigation, animated: true)
    }
}
