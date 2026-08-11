//
//  ViewController.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 06/08/26.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
                
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: remoteFeedLoader,
            imageLoader: remoteImageLoader)
        
        self.addChild(feedViewController)
        feedViewController.didMove(toParent: self)
        self.view.addSubview(feedViewController.view)
        
    }


}

