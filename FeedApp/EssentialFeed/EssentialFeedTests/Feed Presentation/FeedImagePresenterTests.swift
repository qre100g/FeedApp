//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 25/07/26.
//

import UIKit
import XCTest

class FeedImagePresenter {
    init(view: Any) {}
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    class ViewSpy: UIView {
        let messages = [Any]()
    }
    
}
