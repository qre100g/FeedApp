//
//  LoadFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 29/07/26.
//

import XCTest

class LocalFeedImageDataLoader {
    init(store: Any) {
        
    }
}

final class LoadFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let messages = [Any]()
    }
    
}
