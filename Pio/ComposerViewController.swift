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
    
    var maxTweetLenght:Int = 140
    var newTweetPostedCallback: OnNewTweetPostedCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let currentUser = UserManager.singleton.currentUser!
        
        nameLabel.text = currentUser.name
        screenNameLabel.text = "@\(currentUser.screenName)"
        avatarImageView.fadedSetImageWithUrl(NSURL(string: currentUser.biggerProfileImageUrl)!)
        
        charCounter.title = "\(maxTweetLenght)"
        
        compositionField.delegate = self
        compositionField.layer.cornerRadius = 10
        compositionField.layer.borderWidth = 1
        compositionField.layer.borderColor = UIColor.init(colorLiteralRed: 0.1, green: 0.75, blue: 0.875, alpha: 1).CGColor
        compositionField.becomeFirstResponder()
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
            TwitterService.sharedInstance.postUpdate(compositionField.text.trim(),
                replyTo: nil,
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
