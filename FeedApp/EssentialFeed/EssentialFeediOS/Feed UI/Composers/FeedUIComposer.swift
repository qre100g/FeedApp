//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 03/07/26.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = presentationAdapter
        
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController)
        )
        presentationAdapter.presenter = presenter
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
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

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController?, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(loader: loader, model: model)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            
            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak presenter] result in
            switch result {
            case .success(let feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter<
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
