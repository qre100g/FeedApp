//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 13/06/26.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

struct FeedItemMapper {
    
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    static func map(data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            response.statusCode == 200,
            let items = try? JSONDecoder().decode(Root.self, from: data).items
        else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return items
    }
}
