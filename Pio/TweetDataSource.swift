//
//  TweetDataSource.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import UIKit

class TweetDataSource:NSObject, UITableViewDataSource {
    
    private var tableView: UITableView
    private var items:[Tweet] = []
    private var loadTask: TwitterService.NetTask? = nil
    
    init(forTable tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TweetTableViewCell.id, forIndexPath: indexPath) as! TweetTableViewCell
        cell.populate(items[indexPath.row])
        return cell
    }
    
    func reloadData(onCompletion: () -> Void = {}) {
        if loadTask == nil {
            loadTask = TwitterService.sharedInstance.loadTimeline(onSuccess: {
                (tweets) -> Void in
                self.loadTask = nil
                self.items = tweets
                self.tableView.reloadData()
                onCompletion()
                }, onFailure: {
                    onCompletion()
            })
        }
    }
    
    func getItemAt(indexPath: NSIndexPath) -> Tweet {
        return items[indexPath.row]
    }
    
    func prepend(tweet: Tweet) {
        items.insert(tweet, atIndex: 0)
        tableView.reloadData()
    }
}
