//
//  XCTestCase+TrackMemoryLeaks.swift
//  EssentialFeedTests
//
//  Created by Batyr Ovezdurdyyev on 5/11/24.
//

import XCTest

extension XCTestCase {
    
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potensial memory leak.", file: file, line: line)
        }
    }
}
