//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 20/05/26.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Error) -> Void = { _ in } ) {
        client.get(from: url) { _ in
            completion(.connectivity)
        }
    }
}
