//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 28/06/26.
//

import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var onViewAppearing: ((FeedViewController) -> Void)?

    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        onViewAppearing = { vc in
            vc.refresh()
            vc.onViewAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewAppearing?(self)
    }
    
    @objc func refresh() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
