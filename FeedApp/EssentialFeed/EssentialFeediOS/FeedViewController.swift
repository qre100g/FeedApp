//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 28/06/26.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var onViewAppearing: ((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        onViewAppearing = { vc in
            vc.refresh()
            vc.onViewAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewAppearing?(self)
    }
    
    @objc func refresh() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        cell.descriptionLabel.text = model.description
        imageLoader?.loadImageData(from: model.url)
        
        return cell
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let model = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: model.url)
    }
}
