//
//  TweetsViewController.swift
//  Pio
//
//  Created by Andre Oriani on 2/19/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, OnNewTweetPostedCallback {

    var dataSource: TweetDataSource!
    
    @IBOutlet var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        dataSource = TweetDataSource(forTable: tableView)
        let progressDialog = showProgressDialog(attachedTo: topView, message: "Loading Tweets")
        dataSource.reloadData {
            progressDialog.hide(true)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading Tweets")
        refreshControl.tintColor = UIColor.init(colorLiteralRed: 0.34, green: 0.67, blue: 0.934, alpha: 1)
        tableView.insertSubview(refreshControl, atIndex: 0)
        refreshControl.addTarget(self, action: "refreshAction:", forControlEvents: UIControlEvents.ValueChanged)
    }

    func refreshAction(refreshControl: UIRefreshControl) {
        dataSource.reloadData {
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Tweets"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeSegue" {
            self.navigationItem.title = "Cancel"
            let composeVc = segue.destinationViewController as! ComposerViewController
            composeVc.newTweetPostedCallback = self
        }
    }
    
    func onNewTweetPosted(tweet: Tweet) {
        dataSource.prepend(tweet)
    }
}
