//
//  FeedCacheTestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let local = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, image: $0.url) }
    return (feed, local)
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
