//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Batyr Ovezdurdyyev on 5/4/24.
//

import Foundation

// class dalde, protocol etsen has gowy
public protocol HTTPClient {
    func get(from url: URL, competion: @escaping (Error?, HTTPURLResponse?) -> Void)
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
        client.get(from: url) { error, response in
            
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
            
        }
    }
}

