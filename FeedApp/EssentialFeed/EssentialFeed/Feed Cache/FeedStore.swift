//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 19/06/26.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertFeedCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
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
