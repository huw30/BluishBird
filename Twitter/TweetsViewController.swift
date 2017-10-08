//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Raina Wang on 9/27/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetsViewController: TweetListViewController {
    override func loadTweets(maxId: String?, isRefresh: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance.homeTimeline(maxId: maxId, success: { (tweets: [Tweet]) in
            var tweets = tweets
            if tweets.count == 21 {
                tweets.removeFirst()
            }
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
