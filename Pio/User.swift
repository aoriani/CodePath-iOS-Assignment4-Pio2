//
//  User.swift
//  Pio
//
//  Created by Andre Oriani on 2/19/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import ELCodable

struct User: Decodable {
    var name: String
    var screenName: String
    var profileImageUrl: String
    var profileBanner: String?
    var creationDate: String
    var description: String?
    var favoritesCount: Int
    var followersCount: Int
    var followingCount: Int
    var id:String
    var location: String?
    var tweetsCount: Int
    var rawData: NSDictionary?
    
    
    var biggerProfileImageUrl: String {
        get{
            return profileImageUrl.replace("normal", by: "bigger")
        }
    }
    
    var profileBannerUrl: String {
        get{
            return "\(profileBanner)/mobile"
        }
    }
    
    static func decode(json: JSON?) throws -> User {
        return try User(
            name: json ==> "name",
            screenName: json ==> "screen_name",
            profileImageUrl: json ==> "profile_image_url",
            profileBanner: json ==> "profile_banner_url",
            creationDate: json ==> "created_at",
            description: json ==> "description",
            favoritesCount: json ==> "favourites_count",
            followersCount: json ==> "followers_count",
            followingCount: json ==> "friends_count",
            id: json ==> "id_str",
            location: json ==> "location",
            tweetsCount: json ==> "statuses_count",
            rawData: json?.object as? NSDictionary
        )
    }
}