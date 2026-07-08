//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 03/07/26.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    public var view = UIRefreshControl() {
        didSet {
            bindView()
        }
    }
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
        super.init()
        bindView()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func bindView() {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
}
