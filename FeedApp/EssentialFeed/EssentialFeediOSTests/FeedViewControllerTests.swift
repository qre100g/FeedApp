//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Mukesh Kondreddy on 27/06/26.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.simulateViewAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request on view appearing")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request after user initiated reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request after user initiated reload")

        sut.simulateViewAppearance()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected no loading request after view reappeared")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateViewAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the view is appeared")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator after feed is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the user initiated reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the user initiated loading is completed")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func trackMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated", file: file, line: line)
        }
    }
    
    private class FeedLoaderSpy: FeedLoader {
        
        private(set) var loadCompletions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            loadCompletions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCompletions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            loadCompletions[index](.success([]))
        }
    }

}

private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateViewAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            updateRefreshControlWithFake()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func updateRefreshControlWithFake() {
        let fakeRefreshControl = FakeRefreshControl()
        fakeRefreshControl.addTargets(from: refreshControl)
        refreshControl = fakeRefreshControl
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    override var isRefreshing: Bool {
        get { _isRefreshing }
        set { _isRefreshing = newValue }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()

        _isRefreshing = true
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        _isRefreshing = false
    }
    
    func addTargets(from refreshControl: UIRefreshControl?) {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                addTarget(target, action: Selector($0), for: .valueChanged)
            }
        }
    }
}
