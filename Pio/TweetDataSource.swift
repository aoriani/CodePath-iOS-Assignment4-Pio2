//
//  TweetDataSource.swift
//  Pio
//
//  Created by Andre Oriani on 2/20/16.
//  Copyright © 2016 Orion. All rights reserved.
//
// Infinite Loading support is a ripoff of http://guides.codepath.com/ios/Table-View-Guide#adding-infinite-scroll

import Foundation
import UIKit

class TweetDataSource:NSObject, UITableViewDataSource, UIScrollViewDelegate {
    
    private var tableView: UITableView
    private var items:[Tweet] = []
    private var loadTask: NetTask? = nil
    private var subLoadTask: NetTask? = nil
    private var initialLoadEndpoint: InitialLoadEnpoint!
    private var loadMoreEnpoint: LoadMoreEnpoint!
    private var loadingMoreView:InfiniteScrollActivityView?
    
    var isMoreDataLoading = false
    
    init(forTable tableView: UITableView, initialLoadEndpoint: InitialLoadEnpoint, loadMoreEnpoint: LoadMoreEnpoint) {
        self.tableView = tableView
        self.initialLoadEndpoint = initialLoadEndpoint
        self.loadMoreEnpoint = loadMoreEnpoint
        super.init()
        self.tableView.dataSource = self
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
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
        //cancel infinity loading
        subLoadTask?.cancel()
        isMoreDataLoading  = false
        
        if loadTask == nil {
            loadTask = initialLoadEndpoint(TwitterService.sharedInstance)(onSuccess: {
                (tweets) -> Void in
                self.loadTask = nil
                self.items = tweets
                self.tableView.reloadData()
                onCompletion()
                },
                onFailure: {
                    self.loadTask = nil
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()		
            }
        }
    }
    
    private func loadMoreData() {
        //see https://dev.twitter.com/rest/public/timelines
        
        //I still don't know how to do functional programming in swift (aka reduce)
        // so lets do the good for 
        var lowestTweetId = Int64.max
        for tweet in items {
            if tweet.id < lowestTweetId {
                lowestTweetId = tweet.id
            }
        }
        
        subLoadTask = loadMoreEnpoint(TwitterService.sharedInstance)(maxId: (lowestTweetId - 1),
            onSuccess: { tweets in
                self.subLoadTask = nil
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
                
                self.items.appendContentsOf(tweets)
                self.tableView.reloadData()
            },
            onFailure: {
                self.subLoadTask = nil
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
        })
        
    }
}
