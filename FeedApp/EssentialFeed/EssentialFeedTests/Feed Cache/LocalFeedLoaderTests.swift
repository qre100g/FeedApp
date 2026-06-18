//
//  LocalFeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 18/06/26.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCacheCallCount: Int = 0
}

class LocalFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
    
}
