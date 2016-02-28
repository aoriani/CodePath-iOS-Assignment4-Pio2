//
//  ProfileTableViewCell.swift
//  Pio
//
//  Created by Andre Oriani on 2/27/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    static let id = "profileCell"
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var avatarImageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.userInteractionEnabled = false
        
        addShadow(toView: avatarImageview)
        avatarImageview.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageview.layer.borderWidth = 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(user:User) {
        bannerImageView.fadedSetImageWithUrl(NSURL(string: user.profileBannerUrl)!)
        avatarImageview.fadedSetImageWithUrl(NSURL(string: user.biggerProfileImageUrl)!)
        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName)"
        descLabel.text = user.description
        tweetCountLabel.text = String(user.tweetsCount)
        followingCountLabel.text = String(user.followingCount)
        followerCountLabel.text = String(user.followersCount)
    }

}
