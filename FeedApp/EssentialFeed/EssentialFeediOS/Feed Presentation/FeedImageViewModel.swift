//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 05/07/26.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {

    let location: String?
    let description: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }

}
