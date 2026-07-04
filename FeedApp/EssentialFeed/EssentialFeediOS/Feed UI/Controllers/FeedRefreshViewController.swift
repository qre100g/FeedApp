//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 03/07/26.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    public var view = UIRefreshControl() {
        didSet {
            bindView()
        }
    }
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init()
        bindView()
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    private func bindView() {
        viewModel.onFeedLoad = { [weak self] feed in
            self?.onRefresh?(feed)
        }
        
        viewModel.onLoadStatusChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }

        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
}
