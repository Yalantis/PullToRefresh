//
//  CollectionViewController.swift
//  PullToRefreshDemo
//
//  Created by Sergey Prikhodko on 08.04.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

private let pageSize = 100

final class CollectionViewController: UIViewController, PullToRefreshPresentable {

    @IBOutlet private var collectionView: UICollectionView!
    private var dataSourceCount = pageSize
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPullToRefresh(on: collectionView)
    }
    
    @IBAction func refreshAction() {
        collectionView.startRefreshing(at: .top)
    }
    
    @IBAction func openSettings() {
        openSettings(for: collectionView)
    }
    
    func loadAction() {
        dataSourceCount += pageSize
        collectionView.reloadData()
    }
    
    func reloadAction() {
        dataSourceCount = pageSize
        collectionView.reloadData()
    }
    
    deinit {
        collectionView.removeAllPullToRefresh()
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(NumberCollectionViewCell.self)", for: indexPath) as! NumberCollectionViewCell
        cell.titleLabel.text = "\(indexPath.item)"
        
        return cell
    }
}
