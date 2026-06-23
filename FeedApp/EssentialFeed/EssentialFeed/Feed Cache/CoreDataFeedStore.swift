//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 23/06/26.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ images: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertFeedCompletion) {
        
    }
    
    public func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        
    }

}
