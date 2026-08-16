//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 16/08/26.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topViewController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as roo, got \(String(describing: root)) instead")
        XCTAssertTrue(topViewController is FeedViewController, "Expected a FeedViewController as top view controller, got \(String(describing: topViewController)) instead")
    }
    
}
