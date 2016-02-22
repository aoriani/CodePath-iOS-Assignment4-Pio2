//
//  Tweet.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import ELCodable
import DateTools


struct CurrentUserRetweet: Decodable {
    var id: Int64
    
    static func decode(json: JSON?) throws -> CurrentUserRetweet {
        return try CurrentUserRetweet(id: json ==> "id")
    }
}

final class Tweet: Decodable {
    
    static let dateFormatter = NSDateFormatter()
    enum Type {case Regular, Reply, Retweet}
    
    var user: User
    var text: String
    var creationDate: String
    var favoriteCount: Int
    var isUserFavorite: Bool
    var id: Int64
    var replyToScreenName: String?
    var retweetCount:Int
    var wasRetweetedByUser: Bool
    var originalTweet: Tweet?
    var currentUserRetweet: CurrentUserRetweet?
    
    var humandReadableTimestampShort: String  {
        get {
            return getNSDateFromTimestamp().shortTimeAgoSinceNow()
        }
    }
    
    var humandReadableTimestampLong: String {
        let timestamp = getNSDateFromTimestamp()
        Tweet.dateFormatter.dateFormat = "MMMM, d yyyy h:mm a"
        return Tweet.dateFormatter.stringFromDate(timestamp)
    }
    
    
    private func getNSDateFromTimestamp() -> NSDate {
        Tweet.dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y" //What are static blocks in swift ?
        let date = Tweet.dateFormatter.dateFromString(creationDate)!
        return date
    }
    
    var type: Type {
        get {
            if originalTweet != nil {
                return .Retweet
            } else if replyToScreenName != nil {
                return .Reply
            } else  {
                return .Regular
            }
        }
    }
    
    init(
        user: User,
        text: String,
        creationDate: String,
        favoriteCount: Int,
        isUserFavorite: Bool,
        id: Int64,
        replyToScreenName: String?,
        retweetCount:Int,
        wasRetweetedByUser: Bool,
        originalTweet: Tweet?,
        currentUserRetweet: CurrentUserRetweet?) {
            
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
            self.currentUserRetweet = currentUserRetweet
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
            originalTweet: json ==> "retweeted_status",
            currentUserRetweet: json ==> "current_user_retweet"
        )
    }
}
