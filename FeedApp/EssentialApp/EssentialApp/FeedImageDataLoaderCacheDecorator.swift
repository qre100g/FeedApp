//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> any FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoringResult(data, for: url)
                return data
            })
        }
    }
    
}

extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
