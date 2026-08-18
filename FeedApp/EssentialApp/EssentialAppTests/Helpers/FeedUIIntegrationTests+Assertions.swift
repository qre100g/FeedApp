//
//  FeedUIIntegrationTests+Assertions.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/07/26.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
    func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        sut.tableView.enforceLayoutCycle()
        
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
            return
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            return
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date()+1)
    }
    
}
