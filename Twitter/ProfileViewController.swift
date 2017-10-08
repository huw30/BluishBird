//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Raina Wang on 10/6/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: TweetListViewController {
    @IBOutlet weak var profileBackground: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var userDetailsScrollView: UIScrollView!
    @IBOutlet weak var profileBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userDetailControl: UIPageControl!
    @IBOutlet weak var tableHeaderView: UIView!

    var user: User!

    @IBAction func onBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        if user == nil {
            user = User.currentUser
            navigationItem.leftBarButtonItem = nil
        }

        super.viewDidLoad()
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

        tableHeaderView.addBottomBorderWithColor(color: Colors.hexStringToUIColor(hex: "b3b5b7"), width: 0.5)
        navigationItem.title = user.name
        loadSlideView()
    }

    override func loadTweets(maxId: String?, isRefresh: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance.userTimeline(screenname: user.screenname!, maxId: maxId, success: { (tweets: [Tweet]) in
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
            self.isMoreDataLoading = false
            self.refreshControl.endRefreshing()
            self.loadingMoreView!.stopAnimating()
            MBProgressHUD.hide(for: self.view, animated: true)
        }, failure: { (error: Error) in
            Dialog.show(controller: self, title: "Load Tweets Error", message: error.localizedDescription, buttonTitle: "Okay", image: nil, dismissAfter: nil, completion: nil)
        })
    }

    @IBAction func onPageControlTap(_ sender: Any) {
        let x = CGFloat(userDetailControl.currentPage) * userDetailsScrollView.frame.size.width
        userDetailsScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        userDetailControl.currentPage = Int(page)
        animateProfileBGImageView(page: Int(page))

        let offset = scrollView.contentOffset.y

        if offset < -30 {
            self.profileBgHeightConstraint.constant += abs(offset/10)
            self.view.layoutIfNeeded()
        }

        loadMore(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
        UIView.animate(withDuration: 0.1, animations: {
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
