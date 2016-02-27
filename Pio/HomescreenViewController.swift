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
    
    private var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    private var initialLeftMarginContent: CGFloat!
    private var drawerOpen = false

    private var timelineViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addShadow(toView: menuView)
        addShadow(toView: contentView)
        
        timelineViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsNavViewController")
        
        activeViewController = timelineViewController
        
        let currentUser = UserManager.singleton.currentUser!
        userAvatarImageView.fadedSetImageWithUrl(NSURL(string: currentUser.biggerProfileImageUrl)!)
        userNameLabel.text = currentUser.name
        userScreenNameLabel.text = "@\(currentUser.screenName)"
        
    }
    
    func addShadow(toView view:UIView) {
        view.layer.shadowOffset = CGSizeMake(1, 1)
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowRadius = 8.0
        view.layer.shadowOpacity = 0.80
        view.layer.shadowPath = UIBezierPath(rect: view.layer.bounds).CGPath
    }
    
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
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
    
}
