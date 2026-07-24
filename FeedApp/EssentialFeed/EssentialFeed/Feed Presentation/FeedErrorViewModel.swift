//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 25/07/26.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> Self {
        FeedErrorViewModel(message: message)
    }
}
