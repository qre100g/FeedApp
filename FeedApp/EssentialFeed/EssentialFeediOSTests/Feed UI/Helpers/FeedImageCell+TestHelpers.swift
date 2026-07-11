//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var isShowingLocation: Bool {
        locationContainer.isHidden == false
    }
    
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        feedImageRetryButton.isHidden == false
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}
