//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 18/06/26.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    func test_save_requestDeleteCachedFeed() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueItems().models) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestInsertFeedOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueItems().models) { _ in }
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed])
    }
    
    func test_save_requestInsertFeedWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let items = uniqueItems()
        sut.save(items.models) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed, .insert(items: items.local, timestamp: timestamp)])
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
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_doesNotDeliverErrorOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueItems().models) { receivedErrors.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueItems().models) { receivedErrors.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
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
        
        var recievedError: LocalFeedLoader.SaveResult?
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
    
    private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
        let items = [uniqueItem(), uniqueItem()]
        let local = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
        return (items, local)
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
            case insert(items: [LocalFeedItem], timestamp: Date)
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
            _ items: [LocalFeedItem],
            timestamp: Date,
            completion: @escaping InsertFeedCompletion
        ) {
            insertFeedCompletions.append(completion)
            messages.append(.insert(items: items, timestamp: timestamp))
        }
        
        func completeInsertion(with error: Error?, at index: Int = 0) {
            insertFeedCompletions[index](error)
        }
        
        func completeInsertionSuccessfully() {
            completeInsertion(with: nil)
        }
    }
    
}
