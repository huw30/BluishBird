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
    @IBOutlet weak var countDownLabel: UILabel!

    var delegate: ComposeViewControllerDelegate?
    var inReplyTweet: Tweet?

    @IBAction func onCancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onTweetBtn(_ sender: Any) {
        let replyTo = inReplyTweet != nil ? inReplyTweet!.id : nil

        let content = newTweetContent.text

        if let content = content {
            TwitterClient.sharedInstance.composeNew(content: content, replyTo: replyTo, success: { (tweet: Tweet) in
                Dialog.show(controller: self, title: "Success", message: "Tweet added", buttonTitle: nil, image: nil, dismissAfter: 5, completion: { () in
                        self.delegate?.composeViewController?(composeViewController: self, didComposeNewTweet: tweet)
                        self.dismiss(animated: true, completion: nil)
                })
            }, failure: { (error: Error) in
                Dialog.show(controller: self, title: "New Tweet Error", message: error.localizedDescription, buttonTitle: "Okay", image: nil, dismissAfter: nil, completion: nil)
            })
        } else {
            Dialog.show(controller: self, title: "No content", message: "Please add content to your tweet", buttonTitle: "Okay", image: nil, dismissAfter: nil, completion: nil)
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
            newTweetContent.text = "@\(user.screenname!)"
        } else {
            user = User.currentUser
        }

        if let profileURL = user.profileURL {
            avatarImageView.setImageWith(profileURL)
        }

        self.newTweetContent.delegate = self
        self.countDownLabel.text = "140"
        newTweetContent.becomeFirstResponder()

        nameLabel.text = user.name
        screennameLabel.text = "@\(user.screenname!)"
        
        newTweetContent.layer.borderColor = UIColor.gray.cgColor
        newTweetContent.layer.borderWidth = 0.5
        newTweetContent.layer.cornerRadius = 5

        avatarImageView.layer.cornerRadius = 5
        avatarImageView.clipsToBounds = true
    }
}

extension ComposeViewController: UITextViewDelegate {
    func updateCharacterCount() {
        countDownLabel.text = "\((140) - self.newTweetContent.text.characters.count)"
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        newTweetContent.layer.borderColor = Colors.twiterMain.cgColor
        updateCharacterCount()
    }
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCount()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        newTweetContent.layer.borderColor = UIColor.gray.cgColor
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        updateCharacterCount()
        return textView.text.characters.count +  (text.characters.count - range.length) <= 140
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.newTweetContent.endEditing(true)
    }
}
