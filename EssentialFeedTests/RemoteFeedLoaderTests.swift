//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Batyr Ovezdurdyyev on 5/4/24.
//

import XCTest
import EssentialFeed
// @testable goysak, hemme zatlary alya
// goymasak, gerek yerlerimizi public edip cykmaly

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    // naming, test - is test
    // load - method
    // requestDataFromURL - behavior we expect
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
