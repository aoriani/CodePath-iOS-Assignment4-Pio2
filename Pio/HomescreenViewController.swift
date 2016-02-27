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
    
    private var initialLeftMarginContent: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addShadow(toView: menuView)
        addShadow(toView: contentView)
        
    }
    
    func addShadow(toView view:UIView) {
        view.layer.shadowOffset = CGSizeMake(1, 1)
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowRadius = 8.0
        view.layer.shadowOpacity = 0.80
        view.layer.shadowPath = UIBezierPath(rect: view.layer.bounds).CGPath
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
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [.CurveEaseInOut,.LayoutSubviews], animations: {
                if velocity.x > 0 {
                    self.contentViewLeftMargin.constant = self.menuWidth.constant
                } else {
                    self.contentViewLeftMargin.constant = 0
                }
                self.view.layoutIfNeeded()
                }, completion: nil)
            
        default:
            // Do nothing
            break
        }
        
    }
    
}
