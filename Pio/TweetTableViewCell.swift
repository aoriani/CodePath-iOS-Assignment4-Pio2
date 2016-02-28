//
//  TweetTableViewCell.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    static let id = "tweetCell"

    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screnNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTexView: UITextView!
    private var user:User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor.init(colorLiteralRed: 0.9, green: 0.98, blue: 1, alpha: 1)
        
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onAvatarTapped:"))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(tweet: Tweet) {
        timestampLabel.text = tweet.humandReadableTimestampShort
        
        switch (tweet.type) {
        case .Regular:
            retweetLabel.hidden = true
            retweetLabel.text = ""
        case .Reply:
            retweetLabel.hidden = false
            retweetLabel.text = "replied to @\(tweet.replyToScreenName!)"
        case .Retweet:
            retweetLabel.hidden = false
            retweetLabel.text = "\(tweet.user.name) retweeted"
        }
        
        var avatarUrl = ""
        switch (tweet.type) {
        case .Regular,.Reply:
            avatarUrl = tweet.user.biggerProfileImageUrl
        case .Retweet:
            avatarUrl = (tweet.originalTweet?.user.biggerProfileImageUrl)!
        }
        avatarImageView.fadedSetImageWithUrl(NSURL(string: avatarUrl)!)
        
        var name = ""
        switch (tweet.type) {
        case .Regular,.Reply:
            name = tweet.user.name
        case .Retweet:
            name = (tweet.originalTweet?.user.name)!
        }
        nameLabel.text = name

        var screenName = ""
        switch (tweet.type) {
        case .Regular,.Reply:
            screenName = tweet.user.screenName
        case .Retweet:
            screenName = (tweet.originalTweet?.user.screenName)!
        }
        screnNameLabel.text = "@\(screenName)"

        var text = ""
        switch (tweet.type) {
        case .Regular,.Reply:
            text = tweet.text
        case .Retweet:
            text = (tweet.originalTweet?.text)!
        }
        tweetTexView.text = text
        
        switch (tweet.type) {
        case .Regular,.Reply:
            user = tweet.user
        case .Retweet:
            user = (tweet.originalTweet?.user)!
        }


    }

    func onAvatarTapped(gesture: UITapGestureRecognizer) {
        let dict = ["user": UserHolder(withUser: user)]
        NSNotificationCenter.defaultCenter().postNotificationName("avatarTapped", object: self, userInfo: dict)
    }
}
