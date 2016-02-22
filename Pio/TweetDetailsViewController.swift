//
//  TweetDetailsViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/21/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {
    
    @IBOutlet var topView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    
    var newTweetPostedCallback: OnNewTweetPostedCallback?
    var tweet: Tweet!
    
    let likeOff = UIImage(named: "like")
    let likeOn = UIImage(named: "likeOn")
    let retweetOff = UIImage(named: "retweet")
    let retweetOn = UIImage(named: "retweetOn")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImageView.fadedSetImageWithUrl(NSURL(string: tweet.user.biggerProfileImageUrl)!)
        nameLabel.text = tweet.user.name
        screenNameLabel.text = "@" + tweet.user.screenName
        tweetTextView.text = tweet.text
        timestampLabel.text = tweet.humandReadableTimestampLong
        retweetsCountLabel.text = String(tweet.retweetCount)
        likesCountLabel.text = String(tweet.favoriteCount)
        
        likeButton.setImage(tweet.isUserFavorite ? likeOn : likeOff, forState: .Normal)
        retweetButton.setImage(tweet.wasRetweetedByUser ? retweetOn : retweetOff, forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Tweet"
    }

    @IBAction func onReplyButtonPressed(sender: AnyObject) {
        let composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("composeViewControler") as! ComposerViewController
        composeViewController.tweetToReply = tweet
        composeViewController.newTweetPostedCallback = newTweetPostedCallback
        self.navigationItem.title = "Cancel"
        self.navigationController?.pushViewController(composeViewController, animated: true)
    }
    
    @IBAction func retweetButtonPressed(sender: AnyObject) {
        let service = TwitterService.sharedInstance
        let progress = showProgressDialog(attachedTo: topView, message: "Updating...")
        
        func unretweet() {
            var originalId:Int64
            if tweet.originalTweet == nil {
                originalId = tweet.id
            } else { // tweet was itself a retweet
                originalId = tweet.originalTweet!.id
            }
            
            //Retrieve users retweet's id
            service.getTweet(originalId,
                includeRetweet: true,
                onSuccess: { originalTweet in
                    if let retweetId = originalTweet.currentUserRetweet?.id {
                        //Delete retweet
                        service.deleteTweet(retweetId,
                            onSuccess: {
                                self.tweet.retweetCount--
                                self.retweetsCountLabel.text = String(self.tweet.retweetCount)
                                self.tweet.wasRetweetedByUser = false
                                self.retweetButton.setImage(self.retweetOff, forState: .Normal)
                                progress.hide(true)
                            },
                            onFailure: {
                                progress.hide(true)
                        })
                        
                    } else {
                        progress.hide(true)
                    }
                },
                onFailure: {
                    progress.hide(true)
            })
            
        }
        
        if tweet.wasRetweetedByUser {
            unretweet()
        } else {
            service.retweet(tweet.id,
                onSuccess: {
                    _ in
                        self.tweet.retweetCount++
                        self.retweetsCountLabel.text = String(self.tweet.retweetCount)
                        self.tweet.wasRetweetedByUser = true
                        self.retweetButton.setImage(self.retweetOn, forState: .Normal)
                        progress.hide(true)
                }, onFailure: {
                    progress.hide(true)
                })
        }
    
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        let service = TwitterService.sharedInstance
        let progress = showProgressDialog(attachedTo: topView, message: "Updating...")
        if tweet.isUserFavorite {
            service.unlike(tweet.id,
                onSuccess: { _ in
                self.tweet.favoriteCount--
                self.likesCountLabel.text = String(self.tweet.favoriteCount)
                self.tweet.isUserFavorite = false
                self.likeButton.setImage(self.likeOff, forState: .Normal)
                progress.hide(true)
            },
            onFailure: {
                progress.hide(true)
            })
            
        } else {
            service.like(tweet.id,
                onSuccess: { _ in
                    self.tweet.favoriteCount++
                    self.likesCountLabel.text = String(self.tweet.favoriteCount)
                    self.tweet.isUserFavorite = true
                    self.likeButton.setImage(self.likeOn, forState: .Normal)
                    progress.hide(true)
                },
                onFailure: {
                    progress.hide(true)
            })
        }
    }
}
