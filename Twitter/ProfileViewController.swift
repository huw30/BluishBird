//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/6/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController, TweetCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileBackground: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var userDetailsScrollView: UIScrollView!
    @IBOutlet weak var profileBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userDetailControl: UIPageControl!

    var tweets: [Tweet]?
    var user: User!
    var isMoreDataLoading: Bool = false
    var loadingMoreView: InfiniteScrollActivityView?

    @IBAction func onBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        if user == nil {
            user = User.currentUser
            navigationItem.leftBarButtonItem = nil
        }
        setup()
    }

    func loadSlideView() {
        userDetailsScrollView.delegate = self
        userDetailsScrollView.isPagingEnabled = true
        userDetailsScrollView.contentSize = CGSize(width: 345 * 2, height: 50)
        userDetailsScrollView.showsHorizontalScrollIndicator = false

        if let nameView = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as? Slide {
            nameView.name.text = user.name
            nameView.screenname.text = "@\(user.screenname!)"
            nameView.tagline.isHidden = true
            nameView.frame.size.width = 345
            nameView.frame.origin.x = 0
            userDetailsScrollView.addSubview(nameView)
        }
        if let tagLineView = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as? Slide {
            tagLineView.tagline.text = user.tagline
            tagLineView.name.isHidden = true
            tagLineView.screenname.isHidden = true
            tagLineView.frame.size.width = 345
            tagLineView.frame.origin.x = 345
            userDetailsScrollView.addSubview(tagLineView)
        }
    }

    func setup() {
        avatarView.setImageWith(user.profileURL!)
        avatarView.layer.cornerRadius = 5
        avatarView.clipsToBounds = true
        tweetCount.text = "\(user.statusesCount)"
        followingCount.text = "\(user.friendsCount)"
        followerCount.text = "\(user.followersCount)"

        if user.profileBackgroundURL != nil {
            profileBackground.setImageWith(user.profileBackgroundURL!)
            profileBackground.contentMode = .scaleAspectFill
        } else {
            profileBackground.backgroundColor = Colors.hexStringToUIColor(hex: user.profileBackgroundColor!)
        }

        loadSlideView()
        loadTweets(maxId: nil, isRefresh: true)
        addLoadingView()
    }

    func loadTweets(maxId: String?, isRefresh: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance.userTimeline(screenname: user.screenname!, maxId: maxId, success: { (tweets: [Tweet]) in
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

    @IBAction func onPageControlTap(_ sender: Any) {
        let x = CGFloat(userDetailControl.currentPage) * userDetailsScrollView.frame.size.width
        userDetailsScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
}
// MARK: Table delegate methods
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Scroll view delegate
extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        userDetailControl.currentPage = Int(page)
        animateProfileBGImageView(page: Int(page))

        let offset = scrollView.contentOffset.y

        if offset < -30 {
            self.profileBgHeightConstraint.constant += abs(offset/10)
        }
        self.view.layoutIfNeeded()

        loadMore(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.profileBgHeightConstraint.constant > 125 {
            animateHeader()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.profileBgHeightConstraint.constant > 125 {
            animateHeader()
        }
    }
    func animateHeader() {
        self.profileBgHeightConstraint.constant = 125
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    func animateProfileBGImageView(page: Int) {
        UIView.animate(withDuration: 0.3, animations: {
            if page == 0 {
                self.profileBackground.alpha = 1
            } else {
                self.profileBackground.alpha = 0.5
            }
        }, completion: nil)
    }
    func loadMore(_ scrollView: UIScrollView) {
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

