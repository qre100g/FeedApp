//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 05/07/26.
//

import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: Observer<[FeedImage]>?
    var onLoadStatusChange: Observer<Bool>?
    
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
