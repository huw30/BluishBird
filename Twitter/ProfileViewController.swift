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
    @IBOutlet weak var profileBackground: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var screenname: UILabel!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!

    @IBOutlet weak var profileBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileBgTopConstraint: NSLayoutConstraint!

    var tweets: [Tweet]?
    var user: User!

    @IBAction func onBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        if user == nil {
            user = User.currentUser
            self.backButton.title = ""
            self.backButton.isEnabled = false
        }
        setup()
    }
    func setup() {
        name.text = user.name
        screenname.text = "@" + user.screenname!
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        print(offset)
        if offset < -30 {
            self.profileBgHeightConstraint.constant += abs(offset/100)
        } else if offset > 0 {

        }
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
        self.view.layoutIfNeeded()
//        UIView.animate(withDuration: 0.3, animations: {
//            self.view.layoutIfNeeded()
//        }, completion: nil)
    }
}

