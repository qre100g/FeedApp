//
//  FeedImageDataLoaderSpy.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private var message = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedURLs: [URL] {
        message.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> any FeedImageDataLoaderTask {
        message.append((url: url, completion: completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        message[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        message[index].completion(.success(data))
    }
}
    
