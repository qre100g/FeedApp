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

    private var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancel() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = model.location
        cell?.locationContainer.isHidden = !model.hasLocation
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImageContainer.isShimmering = model.isLoading
        cell?.feedImageView.setImageAnimated(model.image)
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

