//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Raina Wang on 9/29/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {


    @IBOutlet weak var retweetedLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var controlGroupView: ControlGroupView!
    @IBOutlet weak var retweeterView: UIView!
    @IBOutlet weak var retweeterViewHeightConstraint: NSLayoutConstraint!

    var tweet: Tweet!
    var parentController: TweetsViewController?

    @IBAction func onHomeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onReplyBtn(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        controlGroupView.tweet = tweet
        controlGroupView.delegate = self
        controlGroupView.setup()
        setup()
    }
    
    func setup() {
        contentLabel.text = tweet.text
        nameLabel.text = tweet.user?.name
        retweetCount.text = "\(tweet.retweetCount)"
        favoriteCount.text = "\(tweet.favoritesCount)"

        if let screenname = tweet.user?.screenname {
            screennameLabel.text = "@\(screenname)"
        }
        if let date = tweet.timestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy, hh:mm a"
            timestampLabel.text = dateFormatter.string(from: date)
        }
        if let profileURL = tweet.user?.profileURL {
            avatarImageView.setImageWith(profileURL)
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.clipsToBounds = true
        }

        if let retweeter = tweet.retweeter {
            retweetedLabel.text = "\(retweeter.name!) retweeted"
            retweeterView.isHidden = false
            retweeterViewHeightConstraint.constant = 16
        } else {
            retweeterView.isHidden = true
            retweeterViewHeightConstraint.constant = 0
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavController = segue.destination as! UINavigationController

        if segue.identifier == "ReplySegue" {
            let btn = sender as! UIButton
            let composeController = destinationNavController.topViewController as? ComposeViewController
            let controlGroupView = btn.superview as! ControlGroupView
            composeController?.inReplyTweet = controlGroupView.tweet
            composeController?.delegate = parentController
        }
    }
}

extension TweetDetailsViewController: ControlGroupViewDelegate {
    func controlGroupView(controlGroupView: ControlGroupView, didTweetChange tweet: Tweet) {
        self.tweet = tweet
        setup()
    }

    func controlGroupViewError(controlGroupView: ControlGroupView, hasError error: Error) {
        Dialog.show(controller: self, title: "error", message: error.localizedDescription, buttonTitle: "Ok", image: nil)
    }
}
