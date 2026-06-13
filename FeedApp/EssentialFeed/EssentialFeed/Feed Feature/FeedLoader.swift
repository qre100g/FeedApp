//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public enum LoadFeedResult<Error> {
	case success([FeedItem])
	case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error
	func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
