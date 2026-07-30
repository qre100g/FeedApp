//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 25/06/26.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var url: URL
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    
    static func images(
        from images: [LocalFeedImage],
        in context: NSManagedObjectContext
    ) -> NSOrderedSet {
        NSOrderedSet(array: images.map { local in
            let managedImage = ManagedFeedImage(context: context)
            managedImage.id = local.id
            managedImage.imageDescription = local.description
            managedImage.location = local.location
            managedImage.url = local.imageURL
            return managedImage
        })
    }
    
    var local: LocalFeedImage {
        return LocalFeedImage(
            id: id,
            description: imageDescription,
            location: location,
            image: url
        )
    }

}
