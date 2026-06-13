//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 13/06/26.
//

import Foundation

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
    
    static func map(data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard
            response.statusCode == 200,
            let items = try? JSONDecoder().decode(Root.self, from: data).feedItems
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(items)
    }
}
