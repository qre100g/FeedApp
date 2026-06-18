//
//  LocalFeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 18/06/26.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed() { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    var deleteCacheCallCount: Int = 0
    var insertFeedCallCount: Int = 0
    var deletionCompletions = [(Error?) -> Void]()
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    
    func deleteCachedFeed(_ completion: @escaping (Error?) -> Void) {
        deleteCacheCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully() {
        completeDeletion(with: nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        insertFeedCallCount += 1
        insertions.append((items, timestamp))
    }
}

class LocalFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
    
    func test_save_requestDeleteCachedFeed() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }
    
    func test_save_doesNotRequestInsertFeedOnDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertFeedCallCount, 0)
    }
    
    func test_save_requestInsertFeedOnDeletionSuccess() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertFeedCallCount, 1)
    }
    
    func test_save_requestInsertFeedWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
    
}
