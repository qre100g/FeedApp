//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 03/07/26.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    public var view = UIRefreshControl() {
        didSet {
            bindView()
        }
    }
    
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
        super.init()
        bindView()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func bindView() {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
}
