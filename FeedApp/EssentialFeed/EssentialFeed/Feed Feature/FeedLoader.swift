//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public enum LoadFeedResult<Error> {
	case success([FeedItem])
	case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

public protocol FeedLoader {
    associatedtype Error
	func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
