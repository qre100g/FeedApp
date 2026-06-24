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
    
    public init(bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.with(name: "FeedStore", in: bundle)
        self.context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ images: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertFeedCompletion) {
        
    }
    
    public func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        
    }

}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }

    static func with(name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle.url(forResource: name, withExtension: "momd").flatMap {
            NSManagedObjectModel(contentsOf: $0)
        }
    }
}
