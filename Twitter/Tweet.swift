//
//  Tweet.swift
//  Twitter
//
//  Created by Raina Wang on 9/26/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    
    init(dictionary: [String: Any]) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorites_count"] as? Int) ?? 0
        
        let timestampString = dictionary["created_at"] as? String

        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }

        let userDictionary = dictionary["user"] as? [String: Any]

        if let userDictionary = userDictionary {
            user = User(dictionary: userDictionary)
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
