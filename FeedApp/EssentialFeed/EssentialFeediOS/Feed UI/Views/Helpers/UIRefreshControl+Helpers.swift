//
//  UIRefreshControl+Helpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 25/07/26.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
