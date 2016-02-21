//
//  TweetDetailsViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/21/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {
    
    var tweet: Tweet!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImageView.fadedSetImageWithUrl(NSURL(string: tweet.user.biggerProfileImageUrl)!)
        nameLabel.text = tweet.user.name
        screenNameLabel.text = "@" + tweet.user.screenName
        tweetTextView.text = tweet.text
        timestampLabel.text = tweet.humandReadableTimestampLong
        retweetsCountLabel.text = String(tweet.retweetCount)
        likesCountLabel.text = String(tweet.favoriteCount ?? 0)
    }

}
