//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
