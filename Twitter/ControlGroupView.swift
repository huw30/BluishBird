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
}

class ControlGroupView: UIView {
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!

    var tweet: Tweet!
    var delegate: ControlGroupViewDelegate?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if (tweet.favorited) {
            favoriteBtn.tintColor = UIColor.red
        } else {
            favoriteBtn.tintColor = UIColor.gray
        }

        if (tweet.retweeted) {
            retweetBtn.tintColor = UIColor.green
        } else {
            retweetBtn.tintColor = UIColor.gray
        }
    }

    @IBAction func onFavBtn(sender: AnyObject) {
        if (!tweet.favorited) {
            TwitterClient.sharedInstance.favorite(id: tweet.id!, success: {
                self.favoriteBtn.tintColor = UIColor.red
                self.tweet.favoritesCount += 1
                self.tweet.favorited = true
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        } else {
            TwitterClient.sharedInstance.unFavorite(id: tweet.id!, success: {
                self.favoriteBtn.tintColor = UIColor.gray
                self.tweet.favoritesCount -= 1
                self.tweet.favorited = false
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }
    }

    @IBAction func onRetweetBtn(sender: AnyObject) {
        if (!tweet.retweeted) {
            TwitterClient.sharedInstance.retweet(id: tweet.id!, success: {
                self.retweetBtn.tintColor = UIColor.green
                self.tweet.retweetCount += 1
                self.tweet.retweeted = true
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        } else {
            TwitterClient.sharedInstance.unRetweet(id: tweet.id!, success: {
                self.retweetBtn.tintColor = UIColor.gray
                self.tweet.retweetCount -= 1
                self.tweet.retweeted = false
                self.delegate?.controlGroupView?(controlGroupView: self, didTweetChange: self.tweet)
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }
    }
}
