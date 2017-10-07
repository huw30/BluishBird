//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/6/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]?
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        user = User.currentUser
        loadTweets(maxId: nil, isRefresh: true)
    }

    func loadTweets(maxId: String?, isRefresh: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance.userTimeline(screenname: user.screenname!, maxId: nil, success: { (tweets: [Tweet]) in
            if isRefresh {
                self.tweets = tweets
            } else {
                self.tweets = self.tweets! + tweets
            }

            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }, failure: { (error: Error) in
            Dialog.show(controller: self, title: "Load Tweets Error", message: error.localizedDescription, buttonTitle: "Okay", image: nil, dismissAfter: nil, completion: nil)
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets {
            return tweets.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as? TweetCell else {
            return TweetCell()
        }
        if let tweets = self.tweets {
            cell.tweet = tweets[indexPath.row]
        }

        cell.delegate = self

        return cell
    }
}
