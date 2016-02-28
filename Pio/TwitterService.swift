//
//  TwitterService.swift
//  Pio
//
//  Created by Andre Oriani on 2/16/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import BDBOAuth1Manager
import ELCodable

typealias NetTask = NSURLSessionDataTask!
typealias InitialLoadMethod = (onSuccess: ([Tweet]) -> Void, onFailure: () -> Void) -> NetTask
typealias InitialLoadEnpoint = (TwitterService ->  InitialLoadMethod)
typealias LoadMoreMethod = (maxId: Int64, onSuccess: ([Tweet]) -> Void, onFailure: () -> Void) -> NetTask
typealias LoadMoreEnpoint = (TwitterService -> LoadMoreMethod)

class TwitterService {
    
    private let session = SessioManager()
    
    static let sharedInstance = TwitterService()
    
    private class SessioManager: BDBOAuth1SessionManager {
        let consumerKey = "aUwq2s9X5CeiNtA7XRFtAkhJy"
        let consumerSecret = "9jAMrAwbuHdshhb2jk37VMX1kOdtsT3f1kD2tbndsQesn3luNu"
        let baseUrl = NSURL(string: "https://api.twitter.com")
        
        private init() {
            super.init(baseURL: baseUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(baseURL url: NSURL?, sessionConfiguration configuration: NSURLSessionConfiguration?) {
            super.init(baseURL: url, sessionConfiguration: configuration)
        }
        
    }
    
    func requestToken(onSuccess onSuccess: (NSURL) -> Void, onFailure: () -> Void = {}){
        session.requestSerializer.removeAccessToken() // Ensure a defined state
        session.fetchRequestTokenWithPath("oauth/request_token",
            method: "POST",
            callbackURL: NSURL(string: "pio://oauth"),
            scope: nil,
            success: {
                requestToken in
                onSuccess(NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!)
            },
            failure: {
                _ in onFailure()
            }
        )
    }
    
    func retrieveToken(oauthDeepLink: NSURL, onSuccess: () -> Void = {}, onFailure: () -> Void = {}) {
        session.fetchAccessTokenWithPath("oauth/access_token",
            method: "POST",
            requestToken: BDBOAuth1Credential(queryString: oauthDeepLink.query),
            success: {
                credentials in
                    self.session.requestSerializer.saveAccessToken(credentials)
                    onSuccess()
            },
            failure: {
              _ in onFailure()
            }
        )
    }
    
    func verifyCredentials(onSuccess onSuccess: (User) -> Void, onFailure: () -> Void = {}) -> NetTask {
        return session.GET("1.1/account/verify_credentials.json",
            parameters: nil,
            success: { (_, response) -> Void in
                do {
                    let json = JSON(response)
                    let result = try User.decode(json)
                    onSuccess(result)
                } catch {
                    onFailure()
                }
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
    
    func removeCredentials() {
        session.requestSerializer.removeAccessToken()
    }
    
    
    private func createRetrieveTweetEndpoint(endpointPath: String, parameters: AnyObject?) -> InitialLoadMethod {
        func endpoint(onSuccess: ([Tweet]) -> Void, onFailure: () -> Void = {}) -> NetTask {
            return session.GET(endpointPath,
                parameters: parameters,
                success: { (_, response) -> Void in
                    do {
                        let array = response as! [NSDictionary]
                        var tweetArray = [Tweet]()
                        for elem in array {
                            let json = JSON(elem)
                            let tweet = try Tweet.decode(json)
                            tweetArray.append(tweet)
                        }
                        onSuccess(tweetArray)
                    } catch {
                        print("Exception")
                        onFailure()
                    }
                },
                failure: { (_, _) -> Void in
                    onFailure()
            })

        }
        
        return endpoint
    }
    
    private func createInitialTweetLoadEnpoint(endpointPath: String) -> InitialLoadMethod {
        let params = ["count": 20]
        return createRetrieveTweetEndpoint(endpointPath, parameters: params)
    }
    
    private func createLoadMoreTweetEndpoint(endpointPath: String, maxId: Int64) -> InitialLoadMethod {
        let params = ["count": 20, "max_id": String(maxId)]
        return createRetrieveTweetEndpoint(endpointPath, parameters: params)
    }
    
    func createloadUserTweetsEndpoint(userId: String) -> InitialLoadMethod {
        let params = ["count": 20, "user_id": userId]
        return createRetrieveTweetEndpoint("1.1/statuses/user_timeline.json", parameters: params)
    }
    
    func createContinueLoadUserTweetsEndpoint(userId: String) -> LoadMoreMethod {
        let method = { (maxId:Int64, onSuccess: ([Tweet]) -> Void, onFailure: () -> Void ) -> NetTask in
            let params = ["count": 20, "user_id": userId, "max_id": String(maxId)]
            return self.createRetrieveTweetEndpoint("1.1/statuses/user_timeline.json", parameters: params)(onSuccess: onSuccess, onFailure: onFailure)
        }
        return method
    }

    func postUpdate(status: String, replyTo: Int64? = nil, onSuccess: (Tweet) -> Void, onFailure: () -> Void = {}) -> NetTask {
        return session.POST("1.1/statuses/update.json",
            parameters: ["status": status.truncate(140), "in_reply_to_status_id": replyTo != nil ? String(replyTo!): ""],
            success: { (_, response) -> Void in
                do {
                    let json = JSON(response)
                    let result = try Tweet.decode(json)
                    onSuccess(result)
                } catch {
                    onFailure()
                }
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
    
    func like(tweetId:Int64, onSuccess: (Tweet) -> Void, onFailure: () -> Void = {}) -> NetTask {
        
        let params = ["id": "\(tweetId)"]
        
        return session.POST("1.1/favorites/create.json",
            parameters: params,
            success: { (_, response) -> Void in
                do {
                    let json = JSON(response)
                    let result = try Tweet.decode(json)
                    onSuccess(result)
                } catch {
                    onFailure()
                }
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
    
    func unlike(tweetId:Int64, onSuccess: (Tweet) -> Void, onFailure: () -> Void = {}) -> NetTask {
        
        let params = ["id": "\(tweetId)"]
        
        return session.POST("1.1/favorites/destroy.json",
            parameters: params,
            success: { (_, response) -> Void in
                do {
                    let json = JSON(response)
                    let result = try Tweet.decode(json)
                    onSuccess(result)
                } catch {
                    onFailure()
                }
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
    
    func retweet(id:Int64, onSuccess: (Tweet) -> Void, onFailure: () -> Void = {}) -> NetTask {
        return session.POST("1.1/statuses/retweet/\(id).json",
            parameters: nil,
            success: { (_, response) -> Void in
                do {
                    let json = JSON(response)
                    let result = try Tweet.decode(json)
                    onSuccess(result)
                } catch {
                    onFailure()
                }
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
    
    func deleteTweet(id:Int64, onSuccess: () -> Void, onFailure: () -> Void = {}) -> NetTask {
        return session.POST("1.1/statuses/destroy/\(id).json",
            parameters: nil,
            success: { (_, response) -> Void in
                    onSuccess()
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
    
    
    func getTweet(tweetId:Int64, includeRetweet: Bool = false, onSuccess: (Tweet) -> Void, onFailure: () -> Void = {}) -> NetTask {
        
        let params = ["id": "\(tweetId)", "include_my_retweet": includeRetweet]
        
        return session.GET("1.1/statuses/show.json",
            parameters: params,
            success: { (_, response) -> Void in
                do {
                    let json = JSON(response)
                    let result = try Tweet.decode(json)
                    onSuccess(result)
                } catch {
                    onFailure()
                }
            },
            failure: { (_, _) -> Void in
                onFailure()
        })
    }
   
}

func loadTimeline(onSuccess: ([Tweet]) -> Void, onFailure: () -> Void = {}) -> NetTask {
    return TwitterService.sharedInstance.createInitialTweetLoadEnpoint("1.1/statuses/home_timeline.json")(onSuccess: onSuccess, onFailure: onFailure)
}

func continueLoadTimeline(maxId:Int64, onSuccess: ([Tweet]) -> Void, onFailure: () -> Void = {}) -> NetTask {
    return TwitterService.sharedInstance.createLoadMoreTweetEndpoint("1.1/statuses/home_timeline.json", maxId: maxId)(onSuccess: onSuccess, onFailure: onFailure)
}

func loadMentions(onSuccess: ([Tweet]) -> Void, onFailure: () -> Void = {}) -> NetTask {
    return TwitterService.sharedInstance.createInitialTweetLoadEnpoint("1.1/statuses/mentions_timeline.json")(onSuccess: onSuccess, onFailure: onFailure)
}

func continueLoadMentions(maxId:Int64, onSuccess: ([Tweet]) -> Void, onFailure: () -> Void = {}) -> NetTask {
    return TwitterService.sharedInstance.createLoadMoreTweetEndpoint("1.1/statuses/mentions_timeline.json", maxId: maxId)(onSuccess: onSuccess, onFailure: onFailure)
}

