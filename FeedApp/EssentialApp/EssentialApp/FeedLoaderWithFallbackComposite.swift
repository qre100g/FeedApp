//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] primaryResult in
            switch primaryResult {
            case let .success(primaryFeed):
                completion(.success(primaryFeed))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
