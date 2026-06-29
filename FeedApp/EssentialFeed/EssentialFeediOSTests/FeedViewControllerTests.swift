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
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the user initiated loading is completed")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.simulateViewAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnLoadError() {
        let image = makeImage()
        let (sut, loader) = makeSUT()

        sut.simulateViewAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image], at: 0)
        assertThat(sut, isRendering: [image])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image])
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
    
    private func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
            return
        }

        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(
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
    
    private func makeImage(description: String? = nil, location: String? = nil) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: URL(string: "https://any-url.com")!)
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
        
        func completeFeedLoading(with images: [FeedImage] = [], at index: Int = 0) {
            loadCompletions[index](.success(images))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any-domain", code: 0)
            loadCompletions[index](.failure(error))
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
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView(tableView, numberOfRowsInSection: feedImagesSection)
    }
    
    func feedImageView(at index: Int = 0) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    var feedImagesSection: Int {
        0
    }
}

private extension FeedImageCell {
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var isShowingLocation: Bool {
        locationContainer.isHidden == false
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
