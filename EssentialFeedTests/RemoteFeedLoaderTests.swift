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
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSONData = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSONData)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyJSONList() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
        
        let (sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(),
                             imageUrl: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(),
                             description: "another description",
                             location: "another location",
                             imageUrl: URL(string: "https://another-url.com")!)
        
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            
            let jsonData = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items] 
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageUrl: imageUrl)
        
        let json: [String: Any] = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString
        ].compactMapValues { $0 }
//        .reduce(into: [String: Any]()) { (acc, e) in
//            if let value = e.value {
//                acc[e.key] = value
//            }
//        }
        return (item, json)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.Result,
                        file: StaticString = #filePath,
                        line: UInt = #line,
                        when action: () -> Void) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map{ $0.url }
        }
        
        func get(from url: URL, competion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, competion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            // test case response should be not nil. Use ! mark
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
}
