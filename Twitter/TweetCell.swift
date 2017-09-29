//
//  TweetCell.swift
//  Twitter
//
//  Created by Raina Wang on 9/29/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetContent: UILabel!
    @IBOutlet weak var timestamp: UILabel!

    var tweet: Tweet!
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup() {
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
        }
    }
}
