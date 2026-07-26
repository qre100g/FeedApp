//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 21/06/26.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("anyData".utf8)
}
