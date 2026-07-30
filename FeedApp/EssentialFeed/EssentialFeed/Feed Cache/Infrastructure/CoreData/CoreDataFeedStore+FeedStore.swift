//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 31/07/26.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return ((feed: $0.localFeed, timestamp: $0.timestamp))
                }
            })
        }
    }
    
    public func insert(
        _ images: [EssentialFeed.LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    ) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: images, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
            
        }
    }

}
