//
//  WeakRefVirtualProxy.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 12/07/26.
//

import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        value?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        value?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        value?.display(viewModel)
    }
}
