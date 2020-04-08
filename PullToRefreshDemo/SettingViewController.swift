//
//  SettingViewController.swift
//  PullToRefreshDemo
//
//  Created by Sergey Prikhodko on 06.04.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import PullToRefresh

class SettingViewController: UIViewController {
    
    @IBOutlet var topSwitch: UISwitch!
    @IBOutlet var bottomSwitch: UISwitch!
    
    weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup(with: scrollView)
    }
    
    
    @IBAction func topSwitchAction(_ sender: UISwitch) {
        scrollView.refresher(at: .top)?.setEnable(isEnabled: sender.isOn)
    }
    @IBAction func bottomSwitchAction(_ sender: UISwitch) {
        scrollView.refresher(at: .bottom)?.setEnable(isEnabled: sender.isOn)
    }
    
    @IBAction func closeAction() {
        navigationController?.dismiss(animated: true)
    }
    
    private func setup(with scrollView: UIScrollView) {
        topSwitch.isOn = scrollView.refresher(at: .top)?.isEnabled ?? false
        topSwitch.isEnabled = scrollView.refresher(at: .top) != nil
        
        bottomSwitch.isOn = scrollView.refresher(at: .bottom)?.isEnabled ?? false
        bottomSwitch.isEnabled = scrollView.refresher(at: .bottom) != nil
    }
}
