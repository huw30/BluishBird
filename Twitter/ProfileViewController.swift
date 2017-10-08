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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var userDetailsScrollView: UIScrollView!
    @IBOutlet weak var profileBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userDetailControl: UIPageControl!

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

        let offset = scrollView.contentOffset.y

        if offset < -30 {
            self.profileBgHeightConstraint.constant += abs(offset/10)
        }
        self.view.layoutIfNeeded()
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
}

