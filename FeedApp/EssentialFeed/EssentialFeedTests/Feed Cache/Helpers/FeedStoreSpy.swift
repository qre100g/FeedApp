//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert(images: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertFeedCompletions = [InsertFeedCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    private(set) var messages = [ReceivedMessages]()
    
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        messages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(
        _ images: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    ) {
        insertFeedCompletions.append(completion)
        messages.append(.insert(images: images, timestamp: timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertFeedCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertFeedCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        messages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success((feed: feed, timestamp: timestamp)))
    }
}
