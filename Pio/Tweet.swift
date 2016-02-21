//
//  Tweet.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import ELCodable

final class Tweet: Decodable {
    var user: User
    var text: String
    var creationDate: String
    var favoriteCount: Int?
    var isUserFavorite: Bool
    var id: Int64
    var replyToScreenName: String?
    var retweetCount:Int
    var wasRetweetedByUser: Bool
    var originalTweet: Tweet?
    
    init(
        user: User,
        text: String,
        creationDate: String,
        favoriteCount: Int?,
        isUserFavorite: Bool,
        id: Int64,
        replyToScreenName: String?,
        retweetCount:Int,
        wasRetweetedByUser: Bool,
        originalTweet: Tweet?) {
            
            self.user = user
            self.text = text
            self.creationDate = creationDate
            self.favoriteCount = favoriteCount
            self.isUserFavorite = isUserFavorite
            self.id = id
            self.replyToScreenName = replyToScreenName
            self.retweetCount = retweetCount
            self.wasRetweetedByUser = wasRetweetedByUser
            self.originalTweet = originalTweet
    }
    
    static func decode(json: JSON?) throws -> Tweet {
        return try Tweet (
            user: json ==> "user",
            text: json ==> "text",
            creationDate: json ==> "created_at",
            favoriteCount: json ==> "favorite_count",
            isUserFavorite: json ==> "favorited",
            id: json ==> "id",
            replyToScreenName: json ==> "in_reply_to_screen_name",
            retweetCount: json ==> "retweet_count",
            wasRetweetedByUser: json ==> "retweeted",
            originalTweet: json ==> "retweeted_status"
        )
    }
}
