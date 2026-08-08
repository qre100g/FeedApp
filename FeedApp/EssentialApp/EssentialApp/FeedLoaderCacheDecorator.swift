//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoreResult(feed)
                return feed
            })
        }
    }
}

extension FeedCache {
    func saveIgnoreResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
