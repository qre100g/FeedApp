//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 19/06/26.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertFeedCompletion = (Error?) -> Void
    
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion)

    func insert(
        _ images: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    )
    
    func retrieve()
}
