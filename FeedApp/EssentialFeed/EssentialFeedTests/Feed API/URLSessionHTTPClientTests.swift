//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 14/06/26.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_failsOnRequestError() {
        URLProtocol.registerClass(URLProtocolSpy.self)
        let sut = URLSessionHTTPClient()
        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolSpy.stub(url: url, error: error)

        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(URLProtocolSpy.self)
    }
    
    // MARK: - Helpers
    
    
    private class URLProtocolSpy: URLProtocol {
        
        static var stubs = [URL: NSError]()
        
        static func stub(url: URL, error: NSError) {
            stubs[url] = error
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let url = request.url, let error = URLProtocolSpy.stubs[url] {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
