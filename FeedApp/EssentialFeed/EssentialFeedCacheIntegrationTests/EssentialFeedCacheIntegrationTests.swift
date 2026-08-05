//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Mukesh Kondreddy on 25/06/26.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    // MARK: - LocalFeedLoader Tests

    func test_loadFeed_deliversNoItemsOnEmptyCache() throws {
        let feedLoader = try makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsOnNonEmptyCache() throws {
        let feedLoaderToPerformSave = try makeFeedLoader()
        let feedLoaderToPerformLoad = try makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, to: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() throws {
        let feedLoaderToPerformFirstSave = try makeFeedLoader()
        let feedLoaderToPerformLastSave = try makeFeedLoader()
        let feedLoaderToPerformLoad = try makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, to: feedLoaderToPerformFirstSave)
        save(latestFeed, to: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toLoad: latestFeed)
    }
    
    func test_valideFeedCache_doesNotDeleteRecentlySavedFeed() throws {
        let feedLoaderToPerformSave = try makeFeedLoader()
        let feedLoaderToPerforValidation = try makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, to: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerforValidation)
        
        expect(feedLoaderToPerformSave, toLoad: feed)
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() throws {
        let imageLoaderToPerformSave = try makeImageLoader()
        let imageLoaderToPerformLoad = try makeImageLoader()
        let feedLoader = try makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()
    
        save([image], to: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() throws {
        let imageLoaderToPerformFirstSave = try makeImageLoader()
        let imageLoaderToPerformLastSave = try makeImageLoader()
        let imageLoaderToPerformLoad = try makeImageLoader()
        let feedLoader = try makeFeedLoader()
        let image = uniqueImage()
        let firstData = anyData()
        let latestData = anyData()
        
        save([image], to: feedLoader)
        save(firstData, for: image.url, with: imageLoaderToPerformFirstSave)
        save(latestData, for: image.url, with: imageLoaderToPerformLastSave)
        
        expect(imageLoaderToPerformLoad, toLoad: latestData, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeFeedLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func makeImageLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func validateCache(
        with loader: LocalFeedLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache validation")
        loader.validateCache { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate feed successully, got error \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case .success(let imageFeed):
                XCTAssertEqual(imageFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toLoad expectedData: Data,
        for url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], to sut: LocalFeedLoader) {
        let exp = expectation(description: "Wait for save completion")
        sut.save(feed) { error in
            XCTAssertNil(error, "Expected save feed without error")
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(
        _ data: Data,
        for url: URL,
        with loader: LocalFeedImageDataLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathExtension("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
