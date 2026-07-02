//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
