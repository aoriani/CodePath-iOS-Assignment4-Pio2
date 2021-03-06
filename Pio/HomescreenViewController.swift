//
//  HomescreenViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/26/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class HomescreenViewController: UIViewController {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    
    private var activeViewController: UINavigationController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    private var initialLeftMarginContent: CGFloat!
    private var drawerOpen = false

    private var timelineViewController: UINavigationController!
    private var mentionsViewController: UINavigationController!
    private var profileViewController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAvatarImageTapped:", name: "avatarTapped", object: nil)
        
        addShadow(toView: menuView)
        addShadow(toView: contentView)
        
        timelineViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsNavViewController") as! UINavigationController
        let timelineController = timelineViewController.topViewController as! TweetsViewController
        timelineController.dataSourceFactoryClosure = {(tableView: UITableView) -> TweetDataSource in
            return TweetDataSource(forTable: tableView, initialLoadEndpoint: loadTimeline, loadMoreEnpoint: continueLoadTimeline)
        }

        
        mentionsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsNavViewController") as! UINavigationController
        let mentionsControler = mentionsViewController.topViewController as! TweetsViewController
        mentionsControler.originalTitle = "Mentions"
        mentionsControler.dataSourceFactoryClosure = {(tableView: UITableView) -> TweetDataSource in
            return TweetDataSource(forTable: tableView, initialLoadEndpoint: loadMentions, loadMoreEnpoint: continueLoadMentions)
        }
        
        let currentUser = UserManager.singleton.currentUser!
        
        profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsNavViewController") as! UINavigationController
        let profileController = profileViewController.topViewController as! TweetsViewController
        profileController.originalTitle = "Profile"
        
        profileController.dataSourceFactoryClosure = {
            (tableView: UITableView) -> TweetDataSource in
                return ProfileTweetDataSource(forTable: tableView, withUser: currentUser, initialLoadEndpoint: TwitterService.sharedInstance.createloadUserTweetsEndpoint(currentUser.id), loadMoreEnpoint: TwitterService.sharedInstance.createContinueLoadUserTweetsEndpoint(currentUser.id))
        }
        

        activeViewController = timelineViewController
        
        userAvatarImageView.fadedSetImageWithUrl(NSURL(string: currentUser.biggerProfileImageUrl)!)
        userNameLabel.text = currentUser.name
        userScreenNameLabel.text = "@\(currentUser.screenName)"
    }
    
    private func removeInactiveViewController(inactiveViewController: UINavigationController?) {
        if let inActiveVC = inactiveViewController {
            
            if inActiveVC.viewControllers.count > 1 {
                inActiveVC.popToRootViewControllerAnimated(false)
            }
            
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = contentView.bounds
            contentView.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMoveToParentViewController(self)
        }
    }
    
    
    @IBAction func onContentPan(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(view)
        let velocity = gesture.velocityInView(view)
        
        switch gesture.state {
        case .Began:
            initialLeftMarginContent = contentViewLeftMargin.constant
        case .Changed:
            let newPosition = initialLeftMarginContent + translation.x
            if newPosition > 0 {
                contentViewLeftMargin.constant = newPosition
            }
        case .Ended:
            toggleDrawer(willOpen: velocity.x > 0)
            
        default:
            // Do nothing
            break
        }
        
    }
    
    private func toggleDrawer(willOpen willOpen:Bool) {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [.CurveEaseInOut,.LayoutSubviews], animations: {
            if willOpen {
                self.contentViewLeftMargin.constant = self.menuWidth.constant
                self.drawerOpen = true
            } else {
                self.contentViewLeftMargin.constant = 0
                self.drawerOpen = false
            }
            self.view.layoutIfNeeded()
            }, completion: nil)
    }


    func onDrawerButtonPressed(sender: UIBarButtonItem){
        toggleDrawer(willOpen: !drawerOpen)
    }
    
    @IBAction func onLogoutPressed(sender: AnyObject) {
        UserManager.singleton.logout()
    }
    
    @IBAction func onTimelinePressed(sender: AnyObject) {
        activeViewController = timelineViewController
        toggleDrawer(willOpen: false)
    }
    
    @IBAction func onMentionsPressed(sender: AnyObject) {
        activeViewController = mentionsViewController
        toggleDrawer(willOpen: false)
    }
    
    @IBAction func onProfilePressed(sender: AnyObject) {
        activeViewController = profileViewController
        toggleDrawer(willOpen: false)
    }
    
    
    func onAvatarImageTapped(notification: NSNotification){
        if activeViewController != profileViewController {
            let dict = notification.userInfo as! [String: UserHolder]
            let user = dict["user"]?.user
            let tweetViewControler = self.storyboard?.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
            tweetViewControler.originalTitle = "@\(user!.screenName)"
            tweetViewControler.dataSourceFactoryClosure = {
                (tableView: UITableView) -> TweetDataSource in
                return ProfileTweetDataSource(forTable: tableView, withUser: user!, initialLoadEndpoint: TwitterService.sharedInstance.createloadUserTweetsEndpoint(user!.id), loadMoreEnpoint: TwitterService.sharedInstance.createContinueLoadUserTweetsEndpoint(user!.id))
            }
            tweetViewControler.navigationItem.leftBarButtonItem = nil
            
            activeViewController?.pushViewController(tweetViewControler, animated: true)
        }
    }
    
    
}

//Wraps the user struct since NS classes only work with NSObjects 
class UserHolder: NSObject {
    
    var user: User
    
    init(withUser user:User){
        self.user = user
        super.init()
    }
    
}
