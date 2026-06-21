//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
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
    
}
