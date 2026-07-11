//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 12/07/26.
//

import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak presenter] result in
            switch result {
            case .success(let feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
