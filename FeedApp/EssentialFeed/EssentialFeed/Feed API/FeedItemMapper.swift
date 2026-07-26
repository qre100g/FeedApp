//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 13/06/26.
//

import Foundation



struct FeedItemMapper {
    
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    static func map(data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            response.isOK,
            let items = try? JSONDecoder().decode(Root.self, from: data).items
        else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return items
    }
}
