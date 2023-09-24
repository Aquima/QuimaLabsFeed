//
//  FeedItem.swift
//  QuimaLabsFeed
//
//  Created by Raul Quispe on 31/05/23.
//

import Foundation

public struct FeedItem: Equatable {
    var id: UUID
    var description: String?
    var location: String?
    var imageURL: String
}
