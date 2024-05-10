//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Batyr Ovezdurdyyev on 5/4/24.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
