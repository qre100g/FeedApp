//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import XCTest
import EssentialFeed

class ValidateCacheUseCaseTests: XCTestCase {
    
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
    
}
