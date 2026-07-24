//
//  UITableView+Dequeueing.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 11/07/26.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
