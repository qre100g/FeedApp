//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
