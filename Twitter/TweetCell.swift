//
//  TweetCell.swift
//  Twitter
//
//  Created by Raina Wang on 9/29/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    @objc optional func showError(tweetCell: TweetCell, hasError error: Error)
    @objc optional func goToProfile(tweetCell: TweetCell)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var retweetedLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetContent: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var controlGroupView: ControlGroupView!
    @IBOutlet weak var retweeterView: UIView!
    @IBOutlet weak var retweeterViewHeightConstraint: NSLayoutConstraint!

    var delegate: TweetCellDelegate?

    var tweet: Tweet! {
        didSet {
            setup()
        }
    }
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action:#selector(handleTap))
        tap.delegate = self
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tap)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup() {
        controlGroupView.tweet = tweet
        controlGroupView.setup()
        controlGroupView.delegate = self

        tweetContent.text = tweet.text
        nameLabel.text = tweet.user?.name
        if let screenname = tweet.user?.screenname {
            usernameLabel.text = "@\(screenname)"
        }
        if let date = tweet.timestamp {
            timestamp.text = DateUtil.timeAgoSince(date: date)
        }
        if let profileURL = tweet.user?.profileURL {
            avatarImage.setImageWith(profileURL)
            avatarImage.layer.cornerRadius = 5
            avatarImage.clipsToBounds = true
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
    func handleTap() {
        delegate?.goToProfile?(tweetCell: self)
    }
}

extension TweetCell: ControlGroupViewDelegate {
    func controlGroupView(controlGroupView: ControlGroupView, didTweetChange tweet: Tweet) {
        self.tweet = tweet
    }

    func controlGroupViewError(controlGroupView: ControlGroupView, hasError error: Error) {
        self.delegate?.showError?(tweetCell: self, hasError: error)
    }
}
