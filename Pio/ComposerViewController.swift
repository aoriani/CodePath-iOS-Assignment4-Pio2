//
//  ComposerViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit


protocol OnNewTweetPostedCallback {
    func onNewTweetPosted(tweet:Tweet)
}

class ComposerViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var topView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var compositionField: UITextView!
    @IBOutlet weak var charCounter: UIBarButtonItem!
    
    
    @IBOutlet weak var repliedTweetContainer: UIView!
    @IBOutlet weak var repliedTweetNameLabel: UILabel!
    @IBOutlet weak var repliedTweetScreenNameLabel: UILabel!
    @IBOutlet weak var repliedTweetTmstpLabel: UILabel!
    @IBOutlet weak var repliedTweetAvatarImageView: UIImageView!
    @IBOutlet weak var repliedTweetTextView: UITextView!
    
    static let MAX_TWEET_SIZE = 140 //Sorry, but i prefer capital letters for constant
    
    private var maxTweetLenght:Int = ComposerViewController.MAX_TWEET_SIZE
    
    var newTweetPostedCallback: OnNewTweetPostedCallback?
    var tweetToReply: Tweet?
    private var replyTweetPrefix = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let currentUser = UserManager.singleton.currentUser!
        
        nameLabel.text = currentUser.name
        screenNameLabel.text = "@\(currentUser.screenName)"
        avatarImageView.fadedSetImageWithUrl(NSURL(string: currentUser.biggerProfileImageUrl)!)
        
        compositionField.delegate = self
        compositionField.layer.cornerRadius = 10
        compositionField.layer.borderWidth = 1
        compositionField.layer.borderColor = UIColor.init(colorLiteralRed: 0.1, green: 0.75, blue: 0.875, alpha: 1).CGColor
        compositionField.becomeFirstResponder()
        
        repliedTweetContainer.layer.cornerRadius = 10
        
        if let tweetToReply = tweetToReply {
            replyTweetPrefix = "@\(tweetToReply.user.screenName) "
            repliedTweetAvatarImageView.fadedSetImageWithUrl(NSURL(string: tweetToReply.user.biggerProfileImageUrl)!)
            repliedTweetNameLabel.text = tweetToReply.user.name
            repliedTweetScreenNameLabel.text = "@\(tweetToReply.user.screenName)"
            repliedTweetTmstpLabel.text = tweetToReply.humandReadableTimestampShort
            repliedTweetTextView.text = tweetToReply.text
            repliedTweetContainer.hidden = false
        } else {
            repliedTweetContainer.hidden = true
        }
        
        maxTweetLenght = ComposerViewController.MAX_TWEET_SIZE - replyTweetPrefix.length
        charCounter.title = "\(maxTweetLenght)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapOutsideKeyboard(sender: AnyObject) {
        compositionField.resignFirstResponder()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //see http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield
        let currentCharacterCount = compositionField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        let newLenghtAllowed = newLength <= maxTweetLenght
        if newLenghtAllowed {
            charCounter.title = "\(maxTweetLenght - newLength)"
        }
        
        return newLenghtAllowed
    }

    @IBAction func onPostButtonClicked(sender: AnyObject) {
        if !compositionField.text.isEmpty {
            let progress = showProgressDialog(attachedTo: topView, message: "Posting tweet ...")
            let newTweet = replyTweetPrefix + compositionField.text.trim()
            TwitterService.sharedInstance.postUpdate(newTweet,
                replyTo: tweetToReply?.user.screenName,
                onSuccess: { (tweet) -> Void in
                    progress.hide(true)
                    self.newTweetPostedCallback?.onNewTweetPosted(tweet)
                    self.navigationController?.popViewControllerAnimated(true)
                },
                onFailure: {
                    progress.hide(true)
                    showErrorDialog("Sorry, something went wrong. Try again later.")
                })
        }
    }
}
