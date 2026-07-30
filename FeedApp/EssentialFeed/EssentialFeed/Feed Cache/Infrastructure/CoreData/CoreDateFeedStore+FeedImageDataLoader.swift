//
//  CoreDateFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 31/07/26.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping (InsertionResult) -> Void
    ) {
        
    }
    
    public func retrieve(
        dataForURL url: URL,
        completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void
    ) {
        completion(.success(.none))
    }
    
}
