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
// @testable gives you access to *internal* types

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // naming, test - is test
    // load - method
    // requestDataFromURL - behavior we expect
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedError: RemoteFeedLoader.Error?
        sut.load { error in capturedError = error
            XCTAssertEqual(capturedError, .connectivity)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, competion: @escaping (Error) -> Void) {
            if let error = error {
                competion(error)
            }
            requestedURLs.append(url)
        }
    }
}
