//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 19/06/26.
//

import Foundation

public class LocalFeedLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    private let store: FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self else { return }
            
            if let error {
                completion(error)
            } else {
                self.insert(images.toLocal(), completion: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success([]))
            }
        }
    }
    
    private func insert(_ images: [LocalFeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(images, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, image: $0.url)
        }
    }
}
