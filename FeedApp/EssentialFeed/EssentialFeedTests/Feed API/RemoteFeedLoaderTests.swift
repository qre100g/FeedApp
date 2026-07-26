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
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let error = NSError(domain: "test", code: 0)
            client.complete(withError: error)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        let data = makeJSON([])
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                client.complete(withCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSONData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversEmptyItemsOn200HTTPResponseWithValidEmptyJSONData() {
        let (sut, client) = makeSUT()
        
        let validEmptyJSON = makeJSON([])
        expect(sut, toCompleteWithResult: .success([])) {
            client.complete(withCode: 200, data: validEmptyJSON)
        }
    }
    
    func test_load_deliversItemsOnValidJSONData() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        
        let json = makeJSON([item1.json, item2.json])
        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            client.complete(withCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultsOnSUTDeallocation() {
        let client = HTTPClientSpy()
        
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "https://a-url.com")!, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load() { capturedResults.append($0) }
        
        sut = nil
        client.complete(withCode: 200, data: makeJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Private Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://example.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithResult expectedResult: RemoteFeedLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Wait for load to complete")
        sut.load() { result in
            switch (expectedResult, result) {
            case let (.success(expectedItems), .success(actualItems)):
                XCTAssertEqual(expectedItems, actualItems, file: file, line: line)
            case let (.failure(expectedError as RemoteFeedLoader.Error), .failure(actualError as RemoteFeedLoader.Error)):
                XCTAssertEqual(expectedError, actualError)
            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead.", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let model = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (model, json)
    }
    
    private func makeJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let jsonData = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return jsonData
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
