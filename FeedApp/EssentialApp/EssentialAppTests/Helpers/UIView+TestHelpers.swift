//
//  UIView+TestHelpers.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 18/08/26.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
