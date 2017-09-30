//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Raina Wang on 9/29/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    @objc optional func composeViewController(composeViewController: ComposeViewController, didComposeNewTweet tweet: Tweet)
}

class ComposeViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var newTweetContent: UITextView!

    var delegate: ComposeViewControllerDelegate?
    var inReplyTweet: Tweet?

    @IBAction func onCancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onTweetBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        let content = newTweetContent.text

        if let content = content {
            TwitterClient.sharedInstance.composeNew(content: content, replyTo: nil, success: { (tweet: Tweet) in
                self.delegate?.composeViewController?(composeViewController: self, didComposeNewTweet: tweet)
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error: Error) in
                //TODO: alert view
                print(error.localizedDescription)
            })
        } else {
            //TODO: no content alert view
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setup() {
        var user: User!

        if let tweet = inReplyTweet {
            user = tweet.user
            newTweetContent.text = "@\(user.screenname!))"
        } else {
            user = User.currentUser
        }

        if let profileURL = user.profileURL {
            avatarImageView.setImageWith(profileURL)
        }

        nameLabel.text = user.name
        screennameLabel.text = user.screenname
    }
}
