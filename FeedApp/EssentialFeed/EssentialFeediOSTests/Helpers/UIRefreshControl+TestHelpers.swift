//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
