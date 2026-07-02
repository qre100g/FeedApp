//
//  FakeRefreshControl.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import UIKit

class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    override var isRefreshing: Bool {
        get { _isRefreshing }
        set { _isRefreshing = newValue }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()

        _isRefreshing = true
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        _isRefreshing = false
    }
    
    func addTargets(from refreshControl: UIRefreshControl?) {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                addTarget(target, action: Selector($0), for: .valueChanged)
            }
        }
    }
}
