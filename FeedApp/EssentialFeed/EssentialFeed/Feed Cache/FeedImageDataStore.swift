//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 30/07/26.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
