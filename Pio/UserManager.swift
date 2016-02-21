//
//  UserManager.swift
//  Pio
//
//  Created by Andre Oriani on 2/19/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import ELCodable


class UserManager {
    
    static let userKey = "user_key"
    static let singleton = UserManager()
    
    static let userDidLoginNotification = "userDidLoginNotification"
    static let userDidLogoutNotification = "userDidLogoutNotification"
    
    
    var currentUser: User? = nil {
        didSet(user) {
           persistUser(currentUser)
        }
    }
    
    private init() {
        self.currentUser = retrieveUser()
    }
    
    private func persistUser(user: User?) {
        do {
            if user?.rawData != nil {
                let data = try NSJSONSerialization.dataWithJSONObject(user!.rawData!, options: NSJSONWritingOptions.PrettyPrinted)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: UserManager.userKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: UserManager.userKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        } catch {
            print ("Failed to serialize user")
        }
    }
    
    private func retrieveUser() -> User? {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(UserManager.userKey) as? NSData
        if let data = data {
            do {
                let json  = JSON(data: data)
                let user = try User.decode(json)
                return user
            } catch {
                print("failed to read user from disk")
            }
            
        }
        return nil
    }
    
    private var inProgressLoginOnSuccess: ((User) -> Void)? = nil
    private var inProgressLoginOnFailure: ((errorMessage: String) -> Void)?
    
    private func clearLoginCallbacks() {
        inProgressLoginOnSuccess = nil
        inProgressLoginOnFailure = nil
    }
    
    func startLoginFlow(onSuccess onSuccess: (User) -> Void, onFailure: (errorMessage: String) -> Void = {_ in }) {
        inProgressLoginOnSuccess = onSuccess
        inProgressLoginOnFailure = onFailure
        
        TwitterService.sharedInstance.requestToken(onSuccess: {
                tokenUrl in UIApplication.sharedApplication().openURL(tokenUrl)
            },
            onFailure: {
                onFailure(errorMessage: "Something went wrong. Please try again later")
                self.clearLoginCallbacks()
            }
        )
    }
    
    func continueLoginFlow(oauthDeepLink: NSURL) {
        if inProgressLoginOnSuccess != nil && inProgressLoginOnFailure != nil {
            TwitterService.sharedInstance.retrieveToken(oauthDeepLink,
                onSuccess: {
                    TwitterService.sharedInstance.verifyCredentials(onSuccess: {
                            user in
                                self.currentUser = user
                                self.inProgressLoginOnSuccess!(user)
                                self.clearLoginCallbacks()
                                NSNotificationCenter.defaultCenter().postNotificationName(UserManager.userDidLoginNotification, object: nil)
                        },
                        onFailure: {
                        self.inProgressLoginOnFailure!(errorMessage: "Could not login on Twitter, please try again later")
                        self.clearLoginCallbacks()
                    })
                
                }, onFailure: {
                    self.inProgressLoginOnFailure!(errorMessage: "Sorry, you must authorize Pio to use your Twitter in order to use it.")
                    self.clearLoginCallbacks()
            })
        } else {
            print("Inconsistent login flow")
        }
    }
    
    func logout() {
        currentUser = nil
        TwitterService.sharedInstance.removeCredentials()
        NSNotificationCenter.defaultCenter().postNotificationName(UserManager.userDidLogoutNotification, object: nil)
    }
    
}
