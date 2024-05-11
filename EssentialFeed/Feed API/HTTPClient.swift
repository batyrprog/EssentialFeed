//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Batyr Ovezdurdyyev on 5/8/24.
//

import Foundation

// class dalde, protocol etsen has gowy
public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
 
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
