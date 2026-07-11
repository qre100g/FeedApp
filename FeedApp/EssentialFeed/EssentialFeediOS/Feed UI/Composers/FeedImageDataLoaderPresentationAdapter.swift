//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 12/07/26.
//

import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<
    View: FeedImageView,
    Image
>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(loader: FeedImageDataLoader, model: FeedImage) {
        self.imageLoader = loader
        self.model = model
    }
    
    func didRequestImage() {
        let model = self.model
        presenter?.didStartImageLoadingData(for: model)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case .failure(let error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
