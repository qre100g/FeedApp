//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Mukesh Kondreddy on 27/06/26.
//

import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var onViewAppearing: ((FeedViewController) -> Void)?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        onViewAppearing = { vc in
            vc.refreshControl?.beginRefreshing()
            vc.refresh()
            vc.onViewAppearing = nil
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewAppearing?(self)
    }
    
    @objc func refresh() {
        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_onViewAppearing_callsLoadFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewAppearance()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_callsLoadFeed() {
        let (sut, loader) = makeSUT()
        sut.simulateViewAppearance()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_onViewAppearingTwice_doesNotLoadFeed() {
        let (sut, loader) = makeSUT()
        sut.simulateViewAppearance()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateViewAppearance()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_onViewAppearing_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        sut.simulateViewAppearance()
        
        XCTAssertTrue(sut.refreshControl?.isRefreshing ?? false)
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
        
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }

}

private extension FeedViewController {
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
