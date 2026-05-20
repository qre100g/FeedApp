//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 20/05/26.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemMapper.map(data: data, response: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

struct FeedItemMapper {
    
    private struct Root: Decodable {
        var items: [Item]
        
        var feedItems: [FeedItem] {
            items.map {
                FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
            }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
    }

    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return try JSONDecoder().decode(Root.self, from: data).feedItems
    }
}
