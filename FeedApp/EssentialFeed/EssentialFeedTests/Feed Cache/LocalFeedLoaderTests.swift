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
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self else { return }
            
            if let error {
                completion(error)
            } else {
                self.store.insert(items, timestamp: self.currentDate()) { [weak self] error in
                    guard self != nil else { return }
                    
                    completion(error)
                }
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertFeedCompletion = (Error?) -> Void
    
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion)

    func insert(
        _ items: [FeedItem],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    )
}

class LocalFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    func test_save_requestDeleteCachedFeed() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestInsertFeedOnDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed])
    }
    
    func test_save_requestInsertFeedWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed, .insert(items: items, timestamp: timestamp)])
    }
    
    func test_save_deliversErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_deliversErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertFeed(with: insertionError)
        })
    }
    
    func test_save_doesNotDeliverErrorOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertFeedSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [Error?]()
        sut?.save([uniqueItem()]) { receivedErrors.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [Error?]()
        sut?.save([uniqueItem()]) { receivedErrors.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertFeed(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
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
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWithError error: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let items = [uniqueItem(), uniqueItem()]
        let exp = expectation(description: "Wait for save completion")
        
        var recievedError: Error?
        sut.save(items) { error in
            recievedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recievedError as? NSError, error, file: file, line: line)
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
    
    private class FeedStoreSpy: FeedStore {
        enum ReceivedMessages: Equatable {
            case deleteCachedFeed
            case insert(items: [FeedItem], timestamp: Date)
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
            _ items: [FeedItem],
            timestamp: Date,
            completion: @escaping InsertFeedCompletion
        ) {
            insertFeedCompletions.append(completion)
            messages.append(.insert(items: items, timestamp: timestamp))
        }
        
        func completeInsertFeed(with error: Error?, at index: Int = 0) {
            insertFeedCompletions[index](error)
        }
        
        func completeInsertFeedSuccessfully() {
            completeInsertFeed(with: nil)
        }
    }
    
}
