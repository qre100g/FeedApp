//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import Foundation
import EssentialFeed

func anyData() -> Data {
    Data("any-data".utf8)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any-domain", code: 0)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}
