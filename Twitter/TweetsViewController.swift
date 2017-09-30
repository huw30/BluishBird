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

    var isMoreDataLoading: Bool = false
    var loadingMoreView: InfiniteScrollActivityView?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        addLoadingView()
        loadTweets(maxId: nil, isRefresh: true)
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

    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadTweets(maxId: nil, isRefresh: true)
    }

    func loadTweets(maxId: String?, isRefresh: Bool) {
        TwitterClient.sharedInstance.homeTimeline(maxId: maxId, success: { (tweets: [Tweet]) in
            if isRefresh {
                self.tweets = tweets
            } else {
                self.tweets = self.tweets! + tweets
            }

            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
        }, failure: { (error: Error) in
            //TODO: AlertView
            print(error.localizedDescription)
        })
    }

    func addLoadingView() {
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)

        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
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

extension TweetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                var maxId: String?

                if let tweets = tweets {
                    let lastTweet = tweets[tweets.count - 1]
                    maxId = lastTweet.id
                }

                loadTweets(maxId: maxId, isRefresh: false)
            }
        }
    }
}
