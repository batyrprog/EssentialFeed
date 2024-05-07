//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Batyr Ovezdurdyyev on 5/4/24.
//

import Foundation

// class dalde, protocol etsen has gowy
public protocol HTTPClient {
    func get(from url: URL, competion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}

