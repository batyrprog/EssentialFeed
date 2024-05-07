//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Batyr Ovezdurdyyev on 5/4/24.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
}
