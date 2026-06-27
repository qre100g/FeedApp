//
//  FeedViewController.swift
//  Prototype
//
//  Created by Mukesh Kondreddy on 27/06/26.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    private let feed = FeedImageViewModel.prototypeFeed
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return feed.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedImageCell
        
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil

        fadeIn(with: UIImage(named: model.imageName))
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
    }
}
