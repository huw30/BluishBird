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
    var user: User?

    @IBAction func onCancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onTweetBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        let content = newTweetContent.text

        if let content = content {
            let escapedContent = content.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            TwitterClient.sharedInstance.composeNew(content: escapedContent!, success: { (tweet: Tweet) in
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
        user = User.currentUser
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setup() {
        if let user = user {
            if let profileURL = user.profileURL {
                avatarImageView.setImageWith(profileURL)
            }
            nameLabel.text = user.name
            screennameLabel.text = user.screenname
        }
    }
}
