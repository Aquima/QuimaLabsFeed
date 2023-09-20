//
//  FeedLoader.swift
//  QuimaLabsFeed
//
//  Created by Raul on 31/05/23.
//

import Foundation
enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult)->Void)
}
