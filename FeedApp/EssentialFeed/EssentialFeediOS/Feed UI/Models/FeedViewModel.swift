//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 05/07/26.
//

import EssentialFeed

final class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: (([FeedImage]) -> Void)?
    var onLoadStatusChange: ((Bool) -> Void)?
    
    func loadFeed() {
        onLoadStatusChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadStatusChange?(false)
        }
    }
}
