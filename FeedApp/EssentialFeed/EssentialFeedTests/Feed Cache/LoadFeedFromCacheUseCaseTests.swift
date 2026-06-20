//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedStore {
        enum ReceivedMessages: Equatable {
            case deleteCachedFeed
            case insert(images: [LocalFeedImage], timestamp: Date)
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
    }
    
}
