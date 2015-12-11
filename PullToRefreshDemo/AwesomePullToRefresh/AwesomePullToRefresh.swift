//
//  AwesomePullToRefresh.swift
//  PullToRefreshDemo
//
//  Created by race on 15/12/10.
//  Copyright © 2015年 Yalantis. All rights reserved.
//

import PullToRefresh

class AwesomePullToRefresh: PullToRefresh {
    convenience init() {
        let refreshView =  NSBundle.mainBundle().loadNibNamed("RefreshView", owner: nil, options: nil).first as! RefreshView
        let animator =  Animator(refreshView: refreshView)
        self.init(refreshView: refreshView, animator: animator)
    }
}