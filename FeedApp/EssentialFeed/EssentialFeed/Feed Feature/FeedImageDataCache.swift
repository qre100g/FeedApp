//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
