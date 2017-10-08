//
//  ControlGroupView.swift
//  Twitter
//
//  Created by Raina Wang on 9/29/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ControlGroupViewDelegate {
    @objc optional func controlGroupView(controlGroupView: ControlGroupView, didTweetChange tweet: Tweet)
    @objc optional func controlGroupViewError(controlGroupView: ControlGroupView, hasError error: Error)
}

class ControlGroupView: UIView {
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favCount: UILabel!

    var tweet: Tweet! {
        didSet {
            setup()
        }
    }
    var delegate: ControlGroupViewDelegate?

    func setup() {
        retweetCount.text = "\(tweet.retweetCount)"
        favCount.text = "\(tweet.favoritesCount)"

        setButtonImages()

        if (tweet.favorited) {
            favoriteBtn.tintColor = Colors.favActive
        } else {
            favoriteBtn.tintColor = UIColor.gray
        }

        if (tweet.retweeted) {
            retweetBtn.tintColor = Colors.retweetActive
        } else {
            retweetBtn.tintColor = UIColor.gray
        }

        replyBtn.tintColor = UIColor.gray
    }

    @IBAction func onFavBtn(sender: AnyObject) {
        if (!tweet.favorited) {
            TwitterClient.sharedInstance.favorite(id: tweet.id!, success: {
                self.favoriteBtn.tintColor = Colors.favActive
                self.tweet.favoritesCount += 1
                self.tweet.favorited = true
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                self.delegate?.controlGroupViewError?(controlGroupView: self, hasError: error)
            })
        } else {
            TwitterClient.sharedInstance.unFavorite(id: tweet.id!, success: {
                self.favoriteBtn.tintColor = UIColor.gray
                self.tweet.favoritesCount -= 1
                self.tweet.favorited = false
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                self.delegate?.controlGroupViewError?(controlGroupView: self, hasError: error)
            })
        }
    }

    @IBAction func onRetweetBtn(sender: AnyObject) {
        if (!tweet.retweeted) {
            TwitterClient.sharedInstance.retweet(id: tweet.id!, success: {
                self.retweetBtn.tintColor = Colors.retweetActive
                self.tweet.retweetCount += 1
                self.tweet.retweeted = true
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                self.delegate?.controlGroupViewError?(controlGroupView: self, hasError: error)
            })
        } else {
            TwitterClient.sharedInstance.unRetweet(id: tweet.id!, success: {
                self.retweetBtn.tintColor = UIColor.gray
                self.tweet.retweetCount -= 1
                self.tweet.retweeted = false
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                self.delegate?.controlGroupViewError?(controlGroupView: self, hasError: error)
            })
        }
    }

    func setButtonImages() {
        let origFavImage = UIImage(named: "favorite")
        let tintedfavImage = origFavImage?.withRenderingMode(.alwaysTemplate)
        favoriteBtn.setImage(tintedfavImage, for: .normal)
        
        let origReplyImage = UIImage(named: "reply")
        let tintedReplyImage = origReplyImage?.withRenderingMode(.alwaysTemplate)
        replyBtn.setImage(tintedReplyImage, for: .normal)
        
        let origRetweetImage = UIImage(named: "retweet")
        let tintedRetweetImage = origRetweetImage?.withRenderingMode(.alwaysTemplate)
        retweetBtn.setImage(tintedRetweetImage, for: .normal)
    }
}
