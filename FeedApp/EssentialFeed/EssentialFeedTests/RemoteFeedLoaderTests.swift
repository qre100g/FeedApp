//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mukesh Kondreddy on 20/05/26.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestFeed() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let error = NSError(domain: "test", code: 0)
            client.complete(withError: error)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withCode: 400, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSONData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversEmptyItemsOn200HTTPResponseWithValidEmptyJSONData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let validEmptyJSON = Data("{ \"items\": [] }".utf8)
            client.complete(withCode: 200, data: validEmptyJSON)
        }
    }
    
    func test_load_deliversItemsOnValidJSONData() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://a-url.com")!)

        let item1JSON: [String: Any] = [
            "id": item1.id.uuidString,
            "description": item1.description as Any,
            "location": item1.location as Any,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
        let item2JSON: [String: Any] = [
            "id": item2.id.uuidString,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWithResult: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withCode: 200, data: json)
        }
    }
    
    // MARK: - Private Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://example.com")!
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithResult result: RemoteFeedLoader.Result,
        when action: @escaping () -> Void
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result])
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
