//
//  TweetListViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/7/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var refreshControl = UIRefreshControl()
    var tweets: [Tweet]?
    
    var isMoreDataLoading: Bool = false
    var loadingMoreView: InfiniteScrollActivityView?
    var isMentionsTimeline: Bool = false
    
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
        
        if (segue.identifier == "ComposeViewSegue" ||
            segue.identifier == "ReplySegue") {
            let composeController = destinationNavController.topViewController as? ComposeViewController
            composeController?.delegate = self
        }
        
        if segue.identifier == "TweetDetailsForCell" {
            let currentCell = sender as? TweetCell
            if currentCell != nil {
                let tweetDetailsController = destinationNavController.topViewController as? TweetDetailsViewController
                tweetDetailsController?.tweet = currentCell!.tweet
                tweetDetailsController?.parentController = self
            }
        }
        
        if segue.identifier == "ReplySegue" {
            let btn = sender as! UIButton
            let composeController = destinationNavController.topViewController as? ComposeViewController
            let controlGroupView = btn.superview as! ControlGroupView
            composeController?.inReplyTweet = controlGroupView.tweet
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadTweets(maxId: nil, isRefresh: true)
    }
    
    func loadTweets(maxId: String?, isRefresh: Bool) {
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

extension TweetListViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets {
            return tweets.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TweetListViewController: ComposeViewControllerDelegate {
    func composeViewController(composeViewController: ComposeViewController, didComposeNewTweet tweet: Tweet) {
        self.tweets?.insert(tweet, at: 0)
        self.tableView.reloadData()
    }
}

extension TweetListViewController: TweetCellDelegate {
    func showError(tweetCell: TweetCell, hasError error: Error) {
        Dialog.show(controller: self, title: "Error", message: error.localizedDescription, buttonTitle: "ok", image: nil, dismissAfter: nil, completion: nil)
    }
    
    func goToProfile(tweetCell: TweetCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileNavController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        let profileViewController = profileNavController.topViewController as! ProfileViewController
        profileViewController.user = tweetCell.tweet.user
        navigationController?.show(profileViewController, sender: self)
    }
}

extension TweetListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // don't load more if there're less than 20 tweets
        if tweets != nil && tweets!.count < 19 {
            isMoreDataLoading = true
        }
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
                
                if tweets != nil && tweets!.count > 0 {
                    let lastTweet = tweets![tweets!.count - 1]
                    maxId = lastTweet.id
                }

                loadTweets(maxId: maxId, isRefresh: false)
            }
        }
    }
}
