//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 25/07/26.
//

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
