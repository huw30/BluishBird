//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Raina Wang on 9/27/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }

    var refreshControl = UIRefreshControl()
    var tweets: [Tweet]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        refreshControl.addTarget(self, action: #selector(loadTweets(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        loadTweets(refreshControl)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavController = segue.destination as! UINavigationController

        if segue.identifier == "ComposeViewSegue" {
            let composeController = destinationNavController.topViewController as? ComposeViewController
            composeController?.delegate = self
        }

        if segue.identifier == "TweetDetailsForCell" {
            let currentCell = sender as? TweetCell
            if currentCell != nil {
                let tweetDetailsController = destinationNavController.topViewController as? TweetDetailsViewController
                tweetDetailsController?.tweet = currentCell!.tweet
            }
        }
    }

    func loadTweets(_ refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }, failure: { (error: Error) in
            //TODO: AlertView
            print(error.localizedDescription)
        })
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as? TweetCell else {
            return TweetCell()
        }
        if let tweets = self.tweets {
            cell.tweet = tweets[indexPath.row]
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets {
            return tweets.count
        }

        return 0
    }
}

extension TweetsViewController: ComposeViewControllerDelegate {
    func composeViewController(composeViewController: ComposeViewController, didComposeNewTweet tweet: Tweet) {
        self.tweets?.insert(tweet, at: 0)
        self.tableView.reloadData()
    }
}
