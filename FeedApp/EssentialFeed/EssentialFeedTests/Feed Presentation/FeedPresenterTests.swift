//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 25/07/26.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
}


protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    let errorView: FeedErrorView

    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingFeed_displaysNoErrorsMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    class ViewSpy: FeedErrorView {
        enum Messages: Equatable {
            case display(errorMessage: String?)
        }

        private(set) var messages = [Messages]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
    
}
