//
//  CoreDataFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 23/06/26.
//

import XCTest
import EssentialFeed

class CoreDataFeedStore: FeedStore {
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    func insert(_ images: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertFeedCompletion) {
        
    }
    
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        
    }

}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoreDataFeedStore()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyStoredFeed() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore()
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
