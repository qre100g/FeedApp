//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let images: [LocalFeedImage]
        let timestamp: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        let decoder = JSONDecoder()
        let feed = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: feed.images, timestamp: feed.timestamp))
    }
    
    func insert(
        _ images: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping FeedStore.InsertFeedCompletion
    ) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(images: images, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for retrieve to finish")
        sut.retrieve() { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for retrieve to finish")
        sut.retrieve() { firstResult in
            sut.retrieve() { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected empty result on calling twice, got \(firstResult) and \(secondResult) instead.")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_deliversCachedFeedOnNonEmptyCache() {
        let sut = makeSUT()
        
        let feedImages = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for retrieve to finish")
        sut.insert(feedImages, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")

            sut.retrieve { result in
                switch result {
                case let .found(receivedFeed, receivedTimestamp):
                    XCTAssertEqual(receivedFeed, feedImages)
                    XCTAssertEqual(receivedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected found with \(feedImages) and \(timestamp), got \(result) instead.")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore()
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
