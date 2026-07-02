//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
