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
    
    private(set) var messages = [ReceivedMessages]()
    
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        messages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully() {
        completeDeletion(with: nil)
    }
    
    func insert(
        _ images: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    ) {
        insertFeedCompletions.append(completion)
        messages.append(.insert(images: images, timestamp: timestamp))
    }
    
    func completeInsertion(with error: Error?, at index: Int = 0) {
        insertFeedCompletions[index](error)
    }
    
    func completeInsertionSuccessfully() {
        completeInsertion(with: nil)
    }
    
    func retrieve() {
        messages.append(.retrieve)
    }
}
