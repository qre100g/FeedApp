//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 19/06/26.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertFeedCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion block can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion)

    /// The completion block can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(
        _ images: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    )

    /// The completion block can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
