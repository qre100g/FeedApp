//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 23/06/26.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.with(name: "FeedStore", url: storeURL, in: bundle)
        self.context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success((feed: cache.localFeed, timestamp: cache.timestamp)))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(
        _ images: [EssentialFeed.LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertFeedCompletion
    ) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: images, in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.find(in: context)
                managedCache.map(context.delete)
                
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
            
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }

}
