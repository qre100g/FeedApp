//
//  FeedImageCellController.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 03/07/26.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {

    private lazy var cell = FeedImageCell()
    private let delegate: FeedImageCellControllerDelegate

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancel() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = !model.hasLocation
        cell.descriptionLabel.text = model.description
        cell.onRetry = delegate.didRequestImage
        cell.feedImageContainer.isShimmering = model.isLoading
        cell.feedImageView.image = model.image
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
    }
}
