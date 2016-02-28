//
//  ProfileTweetDataSource.swift
//  Pio
//
//  Created by Andre Oriani on 2/27/16.
//  Copyright © 2016 Orion. All rights reserved.
//

import Foundation
import UIKit

class ProfileTweetDataSource: TweetDataSource {
    
    private var user:User
    
    init(forTable tableView: UITableView, withUser: User, initialLoadEndpoint: InitialLoadMethod, loadMoreEnpoint: LoadMoreMethod) {
        user = withUser
        super.init(forTable: tableView, initialLoadEndpoint: initialLoadEndpoint, loadMoreEnpoint: loadMoreEnpoint)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  section == 0 {
            return 1
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ProfileTableViewCell.id, forIndexPath: indexPath) as! ProfileTableViewCell
            cell.populate(user)
            return cell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
}