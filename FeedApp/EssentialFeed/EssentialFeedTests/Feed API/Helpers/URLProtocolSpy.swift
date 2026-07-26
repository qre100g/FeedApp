//
//  URLProtocolSpy.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/07/26.
//

import Foundation

class URLProtocolSpy: URLProtocol {
    
    private struct Stub {
        let onStartLoading: (URLProtocolSpy) -> Void
    }
    
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(onStartLoading: { urlProtocol in
            
            guard let client = urlProtocol.client else { return }
            
            if let data = data {
                client.urlProtocol(urlProtocol, didLoad: data)
            }
            
            if let response = response {
                client.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error {
                client.urlProtocol(urlProtocol, didFailWithError: error)
            } else {
                client.urlProtocolDidFinishLoading(urlProtocol)
            }
        })
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(onStartLoading: { urlProtocol in
            urlProtocol.client?.urlProtocolDidFinishLoading(urlProtocol)

            observer(urlProtocol.request)
        })
    }
    
    static func onStartLoading(observer: @escaping () -> Void) {
        stub = Stub(onStartLoading: { _ in observer() })
    }
    
    static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        URLProtocolSpy.stub?.onStartLoading(self)
    }
    
    override func stopLoading() {}
}
