//
//  Tweet.swift
//  Twitter
//
//  Created by Raina Wang on 9/26/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: String?
    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var favorited: Bool = false
    var retweeted: Bool = false
    var user: User?
    var retweeter: User?
    
    init(dictionary: [String: Any]) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        favorited = (dictionary["favorited"] as? Bool) ?? false
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        id = dictionary["id_str"] as? String

        let userDictionary = dictionary["user"] as? [String: Any]
        
        if let userDictionary = userDictionary {
            user = User(dictionary: userDictionary)
        }

        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }

        // check if current is a retweet
        let retweetedTweetDic = dictionary["retweeted_status"] as? [String: Any]
        if let retweetedTweetDic = retweetedTweetDic {
            let timestampString = retweetedTweetDic["created_at"] as? String
            
            if let timestampString = timestampString {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
                timestamp = formatter.date(from: timestampString)
            }

            let originalTweeterDic = retweetedTweetDic["user"] as? [String : Any]
            if let originalTweeterDic = originalTweeterDic {
                let originalTweeter = User(dictionary: originalTweeterDic)
                retweeter = user
                user = originalTweeter
            }

            text = retweetedTweetDic["text"] as? String
        }
    }

    class func tweets(with dictionaries: [[String: Any]]) -> [Tweet] {
        var tweets = [Tweet]()

        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }

        return tweets
    }
}
