//
//  MentionsViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/7/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class MentionsViewController: TweetListViewController {
    override func loadTweets(maxId: String?, isRefresh: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance.mentionsTimeline(maxId: maxId, success: { (tweets: [Tweet]) in
            if isRefresh {
                self.tweets = tweets
            } else {
                self.tweets = self.tweets! + tweets
            }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            MBProgressHUD.hide(for: self.view, animated: true)
            
        }, failure: { (error: Error) in
            Dialog.show(controller: self, title: "Load Tweets Error", message: error.localizedDescription, buttonTitle: "Okay", image: nil, dismissAfter: nil, completion: nil)
        })
    }
}
