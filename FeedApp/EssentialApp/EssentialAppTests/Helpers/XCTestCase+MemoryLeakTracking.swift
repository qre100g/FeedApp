//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialApp
//
//  Created by Mukesh Kondreddy on 08/08/26.
//

import XCTest

extension XCTestCase {
    
    func trackMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated", file: file, line: line)
        }
    }
}
